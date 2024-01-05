pkgs: vars:
let
  goExe = "${pkgs.go}/bin/go";
  envSetup = with vars.hasura;
    "JWT_SECRET=${jwtSecret} HASURA_ADMIN_SECRET=${adminSecret} HASURA_PORT=${port}";
in {
  test = ''
    ${goExe} run github.com/Khan/genqlient
    ${envSetup} ${goExe} test ./...
  '';

  
  seed = ''
    ${goExe} run github.com/Khan/genqlient
    ${envSetup} ${goExe} run ./seed/ $@
  '';
}
