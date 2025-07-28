# TODO: so ugly. use overlays
inputs: pkgs:
pkgs.stdenv.mkDerivation {
  name = "tablet-widgets";

  src = ./.;

  nativeBuildInputs = with pkgs; [
    wrapGAppsHook
    gobject-introspection
    inputs.ags.packages.${system}.default
  ];

  buildInputs = with pkgs; [
    pkgs.glib
    pkgs.gjs

    inputs.astal.packages.${system}.io
    inputs.astal.packages.${system}.astal4
    inputs.astal.packages.${system}.battery
  ];

  installPhase = ''
    mkdir -p $out/bin
    ags bundle app.ts $out/bin/tablet-widgets
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${pkgs.lib.makeBinPath [
        pkgs.hyprland
    ]}
    )
  '';
}
