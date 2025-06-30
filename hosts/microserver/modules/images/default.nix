pkgs: ssot: let
  nixFiles = with pkgs.lib.fileset;
    toList (difference ./. ./default.nix);
  in
  pkgs.lib.attrsets.mergeAttrsList (builtins.map (f: import f pkgs ssot) nixFiles);
