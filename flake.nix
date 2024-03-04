{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    devenv.url = "github:cachix/devenv/v0.6.3";
    flake-utils.url = "github:numtide/flake-utils";
    procfile-nix = {
      url = "github:antholeole/procfile-nix/oleina/prcRunner";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-trusted-public-keys =
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = { self, flake-utils, nixpkgs, devenv, procfile-nix, nixpkgs-unstable, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";
        pkgsUnstable = nixpkgs-unstable.legacyPackages."${system}";

        vars = import ./vars.nix;
        flutter_316 = pkgsUnstable.flutter316;
      in {
        # arion reads this value
        inherit pkgs;

        devShell = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            ({ pkgs, config, ... }:
              let
                postgres = {
                  port = 5432;
                  db = "db";
                };

                procs = procfile-nix.lib.${system}.mkProcfileRunner {
                  name = "devprocs";
                  procGroup = with pkgs; let 
                    watch = dir: exec: "${watchexec}/bin/watchexec -w $DEVENV_ROOT/${dir} ${exec}";
                  in {
                    gqlfetch = watch "hasura/" "\"${graphqurl}/bin/gq http://localhost:${vars.hasura.port}/v1/graphql --introspect -H 'X-Hasura-Admin-Secret: ${vars.hasura.adminSecret}' | tee $DEVENV_ROOT/schema.graphql >> $DEVENV_ROOT/flutter/stdlib/lib/schema.graphql\"";
                    backend = "cd $DEVENV_ROOT && ${lib.getExe arion} up $@";
                  };

                  procRunner = pkgs.honcho;
                };
              in {
                packages = with pkgs; [ 
                  flutter_316
                  arion 
                  docker-compose
                  hasura-cli
                  procs
                ];

                languages = { rust.enable = true; };

                scripts = with pkgs;
                  let e2e = (import ./e2e/run.nix) pkgs vars;
                  in rec {
                    e2eTest.exec = e2e.test;
                    seed.exec = e2e.seed;

                    shopping.exec = "cd $DEVENV_ROOT/flutter/shopping && ${flutter_316}/bin/flutter run -d web-server --web-port 9600";
                  };
              })
          ];
        };
      });
}
