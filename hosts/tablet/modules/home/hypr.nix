{pkgs, ...}: {
  wayland.windowManager.hyprland = {
    plugins = [
      # hyprspace
      # hyprgrass
    ];
  };
}
