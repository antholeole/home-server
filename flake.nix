{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    ## nix utils
    # format the whole repo in one command
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # secrets
    agenix = {
      url = "github:ryantm/agenix";
      # inputs.nixpkgs.follows = "nixpkgs"; does not work with nixos-unstable age
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-root.url = "github:srid/flake-root"; # wtf transitive dependency for agenix-shell?
    agenix-shell = {
      url = "github:aciceri/agenix-shell";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Kubernetes utils
    # CRI
    nix-snapshotter = {
      url = "github:pdtpartners/nix-snapshotter";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Hardware device utils
    # generate a minimal boot iso with my utils
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # format the disk for a device automatically
    disko = {
      url = "github:nix-community/disko";
    };
    # cli for installing nix on devices
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.disko.follows = "disko";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.flake-parts.follows = "flake-parts";
    };
    # hardware config without generating it
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    colmena = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:zhaofengli/colmena/main";
    };

    # helm
    nix-kube-generators = {
      url = "github:farcaller/nix-kube-generators";
    };
    nixhelm = {
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-kube-generators.follows = "nix-kube-generators";
      url = "github:antholeole/nixhelm/vault";
    };

    # some 3p non-helm repo charts
    cloudflare-operator = {
      url = "github:adyanth/cloudflare-operator";
      flake = false;
    };
    baremetal-ingress-nginx = {
      url = "github:kubernetes/ingress-nginx/release-1.12";
      flake = false;
    };

    # code for software
    tldraw-server-client = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:antholeole/tldraw-server-client/main";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.agenix-rekey.flakeModule
        inputs.agenix-shell.flakeModules.default

        ./parts/devshell.nix
        ./parts/treefmt.nix

        ./cdk

        ./.
      ];
      systems = ["x86_64-linux"];

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      } @ sysInputs: {
        _module.args = {
          ssot = import "${inputs.self}/ssot.nix";

          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = let
              overlay = final: prev: {
                lib = let
                  # recurses into ./lib, creating a attrset for every file. so,
                  # `lib/kubernetes.nix` would be accessable by every module
                  # like:
                  #
                  # ```
                  # { lib, ... }: lib.kubernetes.some-custom-function ...
                  # ```
                  #
                  #
                  customLib = prev.lib.filesystem.packagesFromDirectoryRecursive {
                    callPackage = prev.lib.callPackageWith sysInputs;
                    directory = ./lib;
                  };
                in
                  prev.lib
                  // {
                    # add the following to pkgs.lib
                    kubelib = inputs.nix-kube-generators.lib {pkgs = prev;};
                    homeServer = customLib;
                  };

                # and the following to pkgs.
                helm-charts = inputs.nixhelm.charts {pkgs = prev;};

                tldraw-server = inputs'.tldraw-server-client.packages.tldraw-server;
                tldraw-web-client = inputs'.tldraw-server-client.packages.web-frontend;
              };
            in [
              overlay

              # 3rd party overlays
              inputs.nix-snapshotter.overlays.default
            ];
          };
        };
      };
    };
}
