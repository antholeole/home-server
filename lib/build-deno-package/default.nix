# based on https://github.com/addreas/nixlr/blob/5a27140b58cf62fadd58c13a946ab02f73b80356/ui/mk-deno-package.nix#L11
pkgs: {
  pname,
  version,
  src,
}: let
  lib = pkgs.lib;

  lockfile = lib.importJSON "${src}/deno.lock";
  dependencies =
    lib.attrsets.mapAttrsToList
    (url: sha256: {
      inherit url;
      path = pkgs.fetchurl {inherit url sha256;};
      name = "${lib.strings.removePrefix "https://" url}";
    })
    lockfile.remote;
  deno-cache = pkgs.linkFarm "deno-cache" dependencies;

  import-map = let
    generated-imports = builtins.listToAttrs (builtins.map
      (dep: {
        name = dep.url;
        value = "${deno-cache}/${lib.strings.removePrefix "https://" dep.url}";
      })
      dependencies);

    # if we provide an import alias in the import-map.json, override
    # the URL with the fetch generated here.
    manual-imports = builtins.mapAttrs (importAlias: import: generated-imports.${import}) (lib.importJSON "${src}/import-map.json").imports;
  in
    pkgs.writeText "import-map.json" (builtins.toJSON {
      imports = manual-imports // generated-imports;
    });
in
  pkgs.stdenvNoCC.mkDerivation rec {
    inherit pname version src;

    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/bin
      cp -r . $out
      cp ${import-map} $out/import-map.json
      echo "${pkgs.deno}/bin/deno run --import-map $out/import-map.json $out/main.ts \"\$@\"" > $out/bin/${pname}
      chmod +x $out/bin/${pname}
    '';
  }
