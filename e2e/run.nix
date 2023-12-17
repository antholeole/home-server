pkgs: vars: let
    goExe = "${pkgs.go}/bin/go";
in with vars.hasura; ''
${goExe} run github.com/Khan/genqlient
JWT_SECRET=${jwtSecret} HASURA_ADMIN_SECRET=${adminSecret} HASURA_PORT=${port} ${goExe} test ./...
''
