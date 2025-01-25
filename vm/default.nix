{
  withSystem,
  inputs,
  config,
  ...
}: let
  ssot = import "${inputs.self}/ssot/keys.nix";
  mkSpecialArgs = system: {
    inherit inputs system ssot;
  };
in {
  flake = {
    modules.nixos = {
      bootable = ./modules/bootable.nix;
      wifi = ./modules/wifi.nix;
      ssh = ./modules/ssh.nix;

      # hardware modules
      tablet = ./devices/tablet.nix;

      # the abstract default base module, suitable for physical or virtual machines.
      boilerplate = {pkgs, ...}: {
        imports = with config.flake.modules.nixos; [
          inputs.agenix.nixosModules.default
          inputs.disko.nixosModules.disko

          ssh
          # TODO: including wifi in the boilerplate makes it incompatible with
          # cloud vendors.
          wifi
        ];

        time.timeZone = "America/Los_Angeles";
        age.identityPaths = [
          ssot.age-private-key-path

          # in the raw boo iso, the private-key-path is in the /iso directory.
          "/iso${ssot.age-private-key-path}"
        ];

        nix.settings.experimental-features = "nix-command flakes";
        nixpkgs.hostPlatform = "x86_64-linux";
        system.stateVersion = "25.05";
      };
    };

    colmena = {
      meta = {
        nixpkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
        };

        specialArgs = {inherit ssot;};
      };

      # the default physical configuration. should be overridden per device.
      defaults = {pkgs, ...}: {
        replaceUnknownProfiles = true;

        keys."id_ed25519" = {
          keyFile = "~/.secrets/id_ed25519";
          destDir = ssot.age-private-key-path;
        };
      };

      # colmena devices
      tablet.deployment = {ssot, ...}: {
        targetHost = "192.168.12.171";
        targetUser = "manager";
        replaceUnknownProfiles = true;
        tags = ["tablet"];
      };
    };

    # TODO: invert this
    nixosConfigurations.tablet = withSystem "x86_64-linux" ({
      inputs',
      system,
      ...
    }:
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs =
          (mkSpecialArgs system)
          // {
            pkgs = import inputs.nixpkgs {
              inherit system;
            };
          };

        modules = with config.flake.modules.nixos; [
          boilerplate
          tablet
        ];
      });
  };

  perSystem = {
    lib,
    system,
    pkgs,
    inputs',
    ...
  }: rec {
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
