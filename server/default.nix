# https://github.com/NixOS/nixpkgs/pull/358252#issuecomment-2495679635
pkgs:
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "home-server";
  version = "0.1.0";
  src = ./.;

  nativeBuildInputs = with pkgs; [
    jq
    deno.setupHook
    deno.compileHook
  ];

  denoEntrypoints = ["main.ts"];

  denoDeps = pkgs.deno.fetchDeps {
    inherit (finalAttrs) pname src denoEntrypoints;
    hash = "sha256-zzIcz+85OplYD59hNvO7lHiaC90xFydzMsIs5ZfQByI=";
  };
})
