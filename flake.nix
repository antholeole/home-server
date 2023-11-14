{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    devenv.url = "github:cachix/devenv/v0.6.3";
    hasura.url = "github:thenonameguy/graphql-engine/master-nix-gql-engine";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = { self, nixpkgs, devenv, hasura, ... } @ inputs:
    let
      # TODO darwin
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages."${system}";
    in
    {
      devShell."${system}" = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          ({ pkgs, config, ... }: let
            postgres = {
              port = 5432;
              db = "db";
            };
          in {
            packages = with pkgs; [
              flutter
              hasura-cli
            ];

            languages = {

            };

            services.postgres = {
              enable = true;

              listen_addresses = "127.0.0.1";
              port = postgres.port;
            };


            scripts = let
             hasura_bin = hasura.packages."${system}".default;
            in {
              h.exec = "${hasura_bin}/bin/graphql-engine";
            };
          })
        ];
      };
    };
}