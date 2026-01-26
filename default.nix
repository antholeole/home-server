{
  withSystem,
  inputs,
  config,
  self,
  lib,
  ...
}: let
  ssot = import "${inputs.self}/ssot.nix";
  mkSpecialArgs = system:
    withSystem system ({pkgs, ...} @ sysInputs: {
      inherit inputs system ssot;
      pkgs-unstable = import inputs.nixpkgs-unstable {inherit system;};
      flake-config = config;

      # extend lib with custom functions.
      lib = pkgs.lib.extend (final: prev: {
        kubelib = inputs.nix-kube-generators.lib {inherit pkgs;};
        homeServer = prev.filesystem.packagesFromDirectoryRecursive {
          callPackage = prev.callPackageWith sysInputs;
          directory = ./lib;
        };
      });
    });
in {
  flake = {
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
          buildOnTarget = lib.mkDefault true;
        };
      };

      # colmena devices
      hrothgar = {system, ...}: {
        deployment = {
          targetHost = ssot.ips.hrothgar;
          targetUser = "root";
          buildOnTarget = false; #never enough space
          replaceUnknownProfiles = true;
          tags = ["hrothgar" "tablet"];
        };

        imports = [
          (import ./hosts/hrothgar)
        ];
      };

      whiterun = {system, ...}: {
        deployment = {
          targetHost = ssot.ips.whiterun;
          buildOnTarget = false;
          tags = ["router"];
        };

        imports = [
          (import ./hosts/whiterun)
        ];
      };

      riverwood = {system, ...}: {
        deployment = {
          targetHost = ssot.ips.riverwood;
          tags = ["k3s" "master"];
        };

        imports = [
          (import ./hosts/riverwood)
        ];
      };

      blackreach = {system, ...}: {
        deployment = {
          targetHost = ssot.ips.blackreach;
          tags = ["k3s" "master" "nas"];
        };

        imports = [
          (import ./hosts/blackreach)
        ];
      };

      wg-exit = {system, ...}: {
        deployment = {
          targetHost = ssot.ips.wg-exit;
          tags = ["k3s"];
          buildOnTarget = false;
        };

        imports = [
          (import ./hosts/wg-exit)
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
      hrothgar = inputs.nixpkgs.lib.nixosSystem {
        specialArgs =
          mkSpecialArgs system;

        modules = [
          (import ./hosts/hrothgar)
        ];
      };

      whiterun = inputs.nixpkgs.lib.nixosSystem {
        specialArgs =
          mkSpecialArgs system;

        modules = [
          (import ./hosts/whiterun)
        ];
      };

      riverwood = inputs.nixpkgs.lib.nixosSystem {
        specialArgs =
          mkSpecialArgs system;

        modules = [
          (import ./hosts/riverwood)
        ];
      };

      blackreach = inputs.nixpkgs.lib.nixosSystem {
        specialArgs =
          mkSpecialArgs system;

        modules = [
          (import ./hosts/blackreach)
        ];
      };

      wg-exit = inputs.nixpkgs.lib.nixosSystem {
        specialArgs =
          mkSpecialArgs system;

        modules = [
          (import ./hosts/wg-exit)
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
  }: {
    agenix-rekey.nixosConfigurations = ((inputs.colmena.lib.makeHive self.colmena).introspect (x: x)).nodes;

    packages.bootstrap-iso = inputs.nixos-generators.nixosGenerate {
      # meta.description = "the minimal iso required to boot and switch into the full config.";
      inherit system;
      specialArgs = mkSpecialArgs system;

      # imports = [
      #   "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      # ];

      modules = with config.flake.modules.nixos; [
        core
        wifi

        ({...}: {
          virtualisation.diskSize = 30 * 1024;
          networking.networkmanager.enable = true;
          networking.wireless.enable = false;
          networking.hostName = "boot";
        })
      ];

      format = "iso";
    };
  };
}
