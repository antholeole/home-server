{
  withSystem,
  inputs,
  config,
  self,
  ...
}: let
  ssot = import "${inputs.self}/ssot.nix";
  mkSpecialArgs = system: {
    inherit inputs system ssot;
    flake-config = config;
    pkgs = import inputs.nixpkgs {
      inherit system;
    };
  };
in {
  flake = {
    modules.nixos = {
      bootable = ./modules/bootable.nix;
      wifi = ./modules/wifi.nix;
      ssh = ./modules/ssh.nix;
      nix = ./modules/nix.nix;
      disk-efi = ./modules/disk-efi.nix;
      secrets = ./modules/secrets.nix;
      utils = ./modules/utils.nix;

      # the abstract default base module, suitable for physical or virtual machines.
      boilerplate = {pkgs, ...}: {
        imports = with config.flake.modules.nixos; [
          inputs.agenix.nixosModules.default
          inputs.agenix-rekey.nixosModules.default
          inputs.disko.nixosModules.disko

          ssh
          nix
          wifi
          secrets
        ];

        time.timeZone = "America/Los_Angeles";
        nixpkgs.hostPlatform = "x86_64-linux";
        system.stateVersion = "25.05";
      };
    };

    colmena = let
      system = "x86_64-linux";
    in {
      meta = {
        nixpkgs = import inputs.nixpkgs {
          inherit system;
        };

        specialArgs = mkSpecialArgs system;
      };

      # the default physical configuration. should be overridden per device.
      defaults = {pkgs, ...}: {
        deployment = {
          replaceUnknownProfiles = true;
          targetUser = "root";
          buildOnTarget = true;
        };
      };

      # colmena devices
      tablet = {system, ...}: {
        deployment = {
          targetHost = ssot.ips.tablet;
          targetUser = "root";
          buildOnTarget = true; #8gb ram good enough
          replaceUnknownProfiles = true;
          tags = ["tablet"];
        };

        imports = [
          (import ./hosts/tablet)
        ];
      };

      microserver = {system, ...}: {
        deployment = {
          targetHost = ssot.ips.microserver;
          tags = ["server" "master"];
        };

        imports = [
          (import ./hosts/microserver)
        ];
      };
    };

    colmenaHive = inputs.colmena.lib.makeHive self.outputs.colmena;

    # TODO: invert this
    nixosConfigurations = withSystem "x86_64-linux" ({
      inputs',
      system,
      ...
    }: {
      tablet = inputs.nixpkgs.lib.nixosSystem {
        specialArgs =
          mkSpecialArgs system;

        modules = [
          (import ./hosts/tablet)
        ];
      };

      microserver = inputs.nixpkgs.lib.nixosSystem {
        specialArgs =
          mkSpecialArgs system;

        modules = [
          (import ./hosts/microserver)
        ];
      };
    });
  };

  perSystem = {
    lib,
    system,
    pkgs,
    inputs',
    ...
  }: rec {
    agenix-rekey.nixosConfigurations = ((inputs.colmena.lib.makeHive self.colmena).introspect (x: x)).nodes;

    packages.test-only-full-iso = inputs.nixos-generators.nixosGenerate {
      # meta.description = "just to test nixos configurations - don't fully-load an iso!";
      inherit system;

      specialArgs = mkSpecialArgs system;

      modules = [
        (import ./hosts/microserver)

        ({...}: {
          virtualisation.diskSize = 30 * 1024;
        })
      ];

      format = "iso";
    };

    packages.bootstrap-iso = inputs.nixos-generators.nixosGenerate {
      # meta.description = "the minimal iso required to boot and switch into the full config.";
      inherit system;
      specialArgs = mkSpecialArgs system;

      modules = with config.flake.modules.nixos; [
        boilerplate
        bootable

        ({...}: {
          virtualisation.diskSize = 30 * 1024;
        })
      ];

      format = "iso";
    };

    apps = {
      build-iso = {
        program = pkgs.writeShellApplication {
          name = "build-iso";
          runtimeInputs = with pkgs; [libisoburn squashfsTools];
          meta.description = "builds the minimal-bootable iso and injects secrets.";
          text = let
            ageSecretPath = ssot.age-private-key-path;
          in ''
            xorriso -indev ${packages.bootstrap-iso}/iso/nixos-*.iso \
              -outdev iso-with-secrets.iso \
              -map ~/.secrets/id_ed25519 ${ageSecretPath} \
              -boot_image any replay \
              -commit
          '';
        };
      };

      run-iso = {
        type = "app";
        program = pkgs.writeShellApplication {
          meta.description = "runs the secret-injected iso in qemu in a format that is sshable. args: path to iso.";
          name = "run-iso";
          runtimeInputs = [pkgs.qemu];
          text = ''
            qemu-system-x86_64 -net nic \
              -net user,hostfwd=tcp::2222-:22 \
              -enable-kvm -m 256 \
              -cdrom "$@"
          '';
        };
      };

      nixos-anywhere-full = {
        type = "app";
        program = pkgs.writeShellApplication {
          meta.description = "nixos-anywhere a remote host. args: 1: which device, 2: device ip.";
          name = "nixos-anywhere-full";
          runtimeInputs = [
            inputs'.nixos-anywhere.packages.default
          ];
          text = ''
            root=$(mktemp -d)
            mkdir -p "$root"/var/lib/private
            cp ~/.secrets/id_ed25519 "$root"/var/lib/private
            nixos-anywhere --flake .#"$1" root@"$2" -i ~/.secrets/id_ed25519 --extra-files "$root"
          '';
        };
      };
    };
  };
}
