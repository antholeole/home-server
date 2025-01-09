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
        config.packages.client-app
      ];

      packages = with pkgs; [
        pkgs.cargo
      ];

      shellHook = ''
        # https://www.reddit.com/r/tauri/comments/16tzsi8/tauri_desktop_app_not_rendering_but_web_does/
        export WEBKIT_DISABLE_DMABUF_RENDERER=1
        export WEBKIT_DISABLE_COMPOSITING_MODE=1
      '';
    };
  };
}
