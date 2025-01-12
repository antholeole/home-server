{...}: {
  perSystem = {pkgs, ...}: {
    packages.server = pkgs.buildNpmPackage rec {
      name = "home-server";
      src = ./.;
    };
  };
}
