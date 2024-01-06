pkgs: vars:
let
  goExe = "${pkgs.go}/bin/go";
  envSetup = with vars.hasura;
    "JWT_SECRET=${jwtSecret} HASURA_ADMIN_SECRET=${adminSecret} HASURA_PORT=${port}";
in rec {
  generate = ''
    ${goExe} run github.com/Khan/genqlient
  '';

  test = ''
    ${generate}
    ${goExe} clean -testcache
    ${envSetup} ${goExe} test ./... $@
  '';

  seed = ''
    ${generate}
    ${envSetup} ${goExe} run ./seed/ $@
  '';
}
