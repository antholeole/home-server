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
    modules.nixos.boilerplate = {pkgs, ...}: {
      system.stateVersion = "25.05";
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
            overlays = [
              config.flake.modules.nixos.boilerplate
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

      modules = [
        config.flake.modules.nixos.boilerplate

        ({...}: {
          virtualisation.diskSize = 30 * 1024;
        })
      ];

      format = "linode";
    };
  };
}
