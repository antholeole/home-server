# src https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/by-name/po/pot/package.nix#L105
pkgs: let
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "home-server-client-app";
    version = "3.0.5";

    src = ./.;
    sourceRoot = "${finalAttrs.src.name}/src-tauri";

    postPatch = ''
      substituteInPlace $cargoDepsCopy/libappindicator-sys-*/src/lib.rs \
        --replace "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
    '';

    cargoDeps = rustPlatform.importCargoLock {
      lockFile = ./Cargo.lock;
      outputHashes = {
        # All other crates in the same workspace reuse this hash.
        "tauri-plugin-autostart-0.0.0" = "sha256-fgJvoe3rKom2DdXXgd5rx7kzaWL/uvvye8jfL2SNhrM=";
      };
    };

    nativeBuildInputs = with pkgs; [
      rustPlatform.cargoSetupHook
      cargo
      rustc
      cargo-tauri.hook
      nodejs
      wrapGAppsHook3
      pkg-config
    ];

    buildInputs = [
      gtk3
      libsoup
      libayatana-appindicator
      openssl
      webkitgtk_4_0
      xdotool
    ];

    preConfigure = ''
      # pnpm.configHook has to write to .., as our sourceRoot is set to src-tauri
      # TODO: move frontend into its own drv
      chmod +w ..
    '';
  })
