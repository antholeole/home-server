pkgs: vars: let
    goExe = "${pkgs.go}/bin/go";
in ''
${goExe} run github.com/Khan/genqlient
HASURA_ADMIN_SECRET=${vars.hasura.adminSecret} HASURA_PORT=${vars.hasura.port} ${goExe} test ./...
''
