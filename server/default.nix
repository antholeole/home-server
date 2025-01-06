pkgs:
pkgs.buildNpmPackage rec {
  name = "home-server";
  src = ./.;
}
