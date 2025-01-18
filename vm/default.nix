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
          ./ssh.nix
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
    ...
  }: {
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
  };
}
