{
  withSystem,
  inputs,
  config,
  ...
}: let
  specialArgs = system: {
    inherit inputs system;
  };
in {
  flake = {
    modules.nixos = {
      boilerplate = {pkgs, ...}: {
        imports = [
          inputs.agenix.nixosModules.default

          ./ssh.nix
          ./age.nix
          ./wifi.nix
        ];

        system.stateVersion = "25.05";
      };

      bootable = ./bootable.nix;
    };

    nixosConfigurations.master-full = withSystem "x86_64-linux" ({
      inputs',
      system,
      ...
    }:
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs system;
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = with config.flake.modules.nixos; [
              boilerplate

              inputs'.proxmox-nixos.overlays
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
      specialArgs = {
        inherit inputs system;
      };

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
          text = ''
            xorriso -boot_image any keep \
              -dev ${packages.bootstrap-iso}/iso/nixos-*.iso \
              -map <pathtofile>/registration.yaml /livecd-cloud-config.yaml
          '';
        };
      };

      run-iso = {
        type = "app";
        program = pkgs.writeShellApplication {
          name = "run-iso";
          runtimeInputs = [pkgs.qemu];
          text = ''
            qemu-system-x86_64 -net nic \
              -net user,hostfwd=tcp::2222-:22 \
              -enable-kvm -m 256 \
              -cdrom ${packages.bootstrap-iso}/iso/nixos-*.iso
          '';
        };
      };
    };
  };
}
