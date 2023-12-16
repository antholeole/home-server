{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    devenv.url = "github:cachix/devenv/v0.6.3";
    flake-utils.url = "github:numtide/flake-utils";
  };

  nixConfig = {
    extra-trusted-public-keys =
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = { self, flake-utils, nixpkgs, devenv, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";
        vars = import ./vars.nix;
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
              in {
                packages = with pkgs; [ 
                  flutter 
                ];

                languages = {
                  rust.enable = true;
                };

                scripts = with pkgs; rec {
                  fetch.exec = "${graphqurl}/bin/gq http://localhost:${vars.hasura.port}/v1/graphql --introspect -H 'X-Hasura-Admin-Secret: ${vars.hasura.adminSecret}' > $DEVENV_ROOT/schema.graphql";

                  dev.exec = ''
                  cd $DEVENV_ROOT && ${lib.getExe arion} up
                  '';

                  e2e.exec = (import ./e2e/run.nix) pkgs vars;

                  watch.exec = ''
                  ${watchexec}/bin/watchexec -w $DEVENV_ROOT/hasura/ "${fetch.exec}"
                  '';
                };
              })
          ];
        };
      });
}
