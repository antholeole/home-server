{
  lib,
  config,
  ...
}: {
  programs.uwsm.enable = true;
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${lib.getExe config.programs.uwsm.package} start hyprland-uwsm.desktop";
        user = "manager";
      };

      default_session = initial_session;
    };
  };
}
