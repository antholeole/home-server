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
      pkgs_24_11 = import inputs.nixpkgs_24_11 {
        inherit system;
        config.permittedInsecurePackages = [
          "k3s-1.29.15+k3s1"
        ];
      };
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
    modules.nixos = {
      bootable = ./modules/bootable.nix;
      wifi = ./modules/wifi.nix;
      ssh = ./modules/ssh.nix;
      nix = ./modules/nix.nix;
      disk-efi = ./modules/disk-efi.nix;
      secrets = ./modules/secrets.nix;
      dev = ./modules/dev.nix;
      sensible = ./modules/sensible.nix;

      configure-pkgs = {
        pkgs,
        system,
        ...
      }: {
        nixpkgs = {
          overlays = let
            overlay = final: prev:
              withSystem system ({
                inputs',
                config,
                ...
              }: {
                # and the following to pkgs.
                helm-charts = inputs.nixhelm.charts {pkgs = prev;};

                manifests = config.packages.manifests;
                tldraw-server = inputs'.tldraw-server-client.packages.tldraw-server;
                tldraw-web-client = inputs'.tldraw-server-client.packages.web-frontend;
              });
          in [
            overlay

            # 3rd party overlays
            inputs.nix-snapshotter.overlays.default
            inputs.nixzx.overlays.default
          ];
        };
      };

      # the abstract default base module, suitable for physical or virtual machines.
      boilerplate = {pkgs, ...}: {
        imports = with config.flake.modules.nixos; [
          inputs.agenix.nixosModules.default
          inputs.agenix-rekey.nixosModules.default
          inputs.disko.nixosModules.disko

          configure-pkgs
          sensible
          ssh
          nix
          wifi
          secrets
          dev
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
          tags = ["hrothgar"];
        };

        imports = [
          (import ./hosts/hrothgar)
        ];
      };

      riverwood = {system, ...}: {
        deployment = {
          targetHost = ssot.ips.riverwood;
          tags = ["server" "master"];
        };

        imports = [
          (import ./hosts/riverwood)
        ];
      };

      whiterun = {system, ...}: {
        deployment = {
          targetHost = ssot.ips.whiterun;
          buildOnTarget = false; 
          tags = ["router" "server"];
        };

        imports = [
          (import ./hosts/whiterun)
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

      riverwood = inputs.nixpkgs.lib.nixosSystem {
        specialArgs =
          mkSpecialArgs system;

        modules = [
          (import ./hosts/riverwood)
        ];
      };

      whiterun = inputs.nixpkgs.lib.nixosSystem {
        specialArgs =
          mkSpecialArgs system;

        modules = [
          (import ./hosts/whiterun)
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

      modules = with config.flake.modules.nixos; [
        configure-pkgs
        nix
        dev
        bootable
        ssh

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
