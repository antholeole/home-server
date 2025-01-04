pkgs:
pkgs.stdenv.mkDerivation rec {
  pname = "home-server";
  version = "0.1.0";

  src = ./.;

  buildInputs = with pkgs; [
    deno
  ];

  buildPhase = ''
    deno compile .
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv chord $out/bin
  '';
}
