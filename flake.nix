{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

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

    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

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
      url = "github:antholeole/nixhelm/oleina/qryyoztowrux";
    };

    # code for software
    tldraw-server-client = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:antholeole/tldraw-server-client/main";
    };

    # setup the manager user on hrothgars
    home-manager.url = "github:nix-community/home-manager";

    # hrothgar ui
    hyprland.url = "github:hyprwm/Hyprland";

    ags = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:antholeole/ags/oleina/systemddefines";
    };

    astal = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:aylur/astal";
    };

    nixzx = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:antholeole/nixzx";
    };

    # these are encrypted I'm just scared
    secrets = {
      flake = false; # it actually is we just only need the source
      url = "git+ssh://git@github.com/antholeole/home-server-secrets";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.agenix-rekey.flakeModule
        inputs.agenix-shell.flakeModules.default

        inputs.home-manager.flakeModules.home-manager

        ./modules

        ./parts/devshell.nix
        ./parts/treefmt.nix

        ./cdk8s

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
      }: {
        _module.args = {
          pkgs = import inputs.nixpkgs {
            inherit system;

            overlays = [
              (prev: next: {
                agsFull = inputs.ags.packages.${prev.system}.agsFull; # full for devel
                astral = inputs.astral.packages.${prev.system}.default;
              })
            ];
          };

          ssot = import "${inputs.self}/ssot.nix";
        };
      };
    };
}
