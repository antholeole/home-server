{pkgs, ...}: {
  wayland.windowManager.hyprland = {
    plugins = with pkgs.hyprlandPlugins; [
      hyprspace
      hyprgrass
    ];
  };

  home.file."~/.config/hypr/hyprland.conf".source = ./hypr.conf;

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "off";

      preload = ["${./yosemite_bg.jpg}"];
      wallpaper = ", ${./yosemite_bg.jpg}";
    };
  };
}
