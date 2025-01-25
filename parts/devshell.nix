{inputs, ...}: {
  perSystem = {
    system,
    pkgs,
    lib,
    config,
    inputs',
    ...
  }: {
    procfiles = let
      procfileBase = {
        procRunner = pkgs.honcho;
        processes = {
          server = "cd $ROOT_DIR/server/ && npm run dev";
        };
      };
    in {
      tauri-dev =
        lib.attrsets.recursiveUpdate procfileBase
        {
          processes.tauri = "cd $ROOT_DIR/client/ && npm run tauri dev";
        };

      fe-dev =
        lib.attrsets.recursiveUpdate procfileBase
        {
          processes.fe = "cd $ROOT_DIR/client/ && npm run dev";
        };
    };

    devShells.default = pkgs.mkShell {
      inputsFrom = [
        config.packages.server
        config.packages.client-app
      ];

      packages = with pkgs; [
        cargo
        libisoburn

        inputs'.agenix.packages.default
        inputs'.colmena.packages.colmena
        inputs'.nixos-anywhere.packages.default

        config.procfiles.tauri-dev.package
        config.procfiles.fe-dev.package
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
