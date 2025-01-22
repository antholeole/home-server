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
    modules.nixos = rec {
      bootable = ./bootable.nix;
      wifi = ./wifi.nix;
      ssh = ./ssh.nix;

      boilerplate = {pkgs, ...}: {
        imports = [
          inputs.agenix.nixosModules.default

          ssh
          # TODO: including wifi in the boilerplate makes it incompatible with
          # cloud vendors.
          wifi
        ];

        age.identityPaths = [
          ssot.age-private-key-path

          # in the raw boo iso, the private-key-path is in the /iso directory.
          "/iso${ssot.age-private-key-path}"
        ];
        system.stateVersion = "25.05";
      };
    };

    nixosConfigurations.master-full = withSystem "x86_64-linux" ({
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
              overlays = with config.flake.modules.nixos; [
                boilerplate
              ];
            };
          };
      });
  };

  perSystem = {
    lib,
    system,
    pkgs,
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
    };
  };
}
