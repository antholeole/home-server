{
  lib,
  pkgs,
  ...
}: let
  keymapScript = pkgs.writeZxApplication {
    name = "notify-lock-pressed";
    runtimeInputs = [
      pkgs.hyprland
    ];

    src = ./notify-lock-pressed.ts;
  };
in {
  options.programs.notify-lock-pressed.package = with lib;
    mkOption {
      type = types.package;
      readOnly = true;
      default = keymapScript;
    };

  config.home.packages = [
    keymapScript
  ];
}
