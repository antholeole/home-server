{inputs, ...}: {
  perSystem = {
    system,
    pkgs,
    lib,
    inputs',
    config,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        cargo
        libisoburn

        inputs'.colmena.packages.colmena
        inputs'.nixos-anywhere.packages.default

        config.agenix-rekey.package
      ];

      shellHook = ''
        # https://www.reddit.com/r/tauri/comments/16tzsi8/tauri_desktop_app_not_rendering_but_web_does/
        export WEBKIT_DISABLE_DMABUF_RENDERER=1
        export WEBKIT_DISABLE_COMPOSITING_MODE=1

        git config --local blame.ignoreRevsFile .git-blame-ignore-revs
      '';
    };
  };
}
