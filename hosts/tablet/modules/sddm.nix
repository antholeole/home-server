{
  pkgs,
  lib,
  ...
}: let
  kwin = lib.concatStringsSep " " [
    "${lib.getBin pkgs.kdePackages.kwin}/bin/kwin_wayland"
    "--no-global-shortcuts"
    "--no-kactivities"
    "--no-lockscreen"
    "--locale1"
    "--inputmethod maliit-keyboard"
  ];
in {
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    settings = {
      Wayland = {
        CompositorCommand = kwin;
      };
    };
  };
}
