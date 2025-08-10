{...}: {
  services.logind = {
    powerKeyLongPress = "poweroff";
    powerKey = "suspend";
  };
}
