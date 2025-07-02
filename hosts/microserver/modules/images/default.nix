pkgs: ssot: let
  nixFiles = with pkgs.lib.fileset;
    toList (difference ./. ./default.nix);
  nameToTarPath = pkgs.lib.attrsets.mergeAttrsList (builtins.map (f: import f pkgs ssot) nixFiles);
in
  pkgs.lib.attrsets.concatMapAttrs (image: tar-path: {
    ${image} = "nix:0${tar-path}";
  })
  nameToTarPath
