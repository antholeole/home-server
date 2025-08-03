{...}: {
  services.logind = {
    powerKeyLongPress = "poweroff";

    # will power off screen, as handled by hyprland.
    powerKey = "ignore";
  };

  # todo: suspend from hyprland
  # todo: suspend after idle
}
