pkgs: let
  buildDenoPackage = (import ../lib/build-deno-package) pkgs;
in
  buildDenoPackage {
    pname = "home-server";
    version = "0.1.0";
    src = ./.;
  }
