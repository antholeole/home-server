{inputs, ...}: {
  perSystem = {
    system,
    pkgs,
    config,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      inputsFrom = [
        config.packages.server
      ];

      packages = with pkgs; [
        pkgs.cargo-tauri

        # todo move this to buildInputs of the tauri proj
        pkgs.gtk3
        pkgs.libsoup_2_4
        pkgs.atk
        pkgs.rust-bin.beta.latest.default
        pkgs.gdk-pixbuf
      ];
    };
  };
}
