{pkgs, ...}: {
  home.packages = with pkgs; [
    hyprpaper
  ];
  
  wayland.windowManager.hyprland = {
    systemd.enable = true;
    # required or else there are some issues -\_()_/-
    package = pkgs.hyprland;
    plugins = with pkgs.hyprlandPlugins; [
      hyprspace
      hyprgrass
    ];
  };

  home.file.".config/hypr/hyprland.conf".source = ./hypr.conf;

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "off";
      splash = false;

      preload = ["${./yosemite_bg.jpg}"];
      wallpaper = ", ${./yosemite_bg.jpg}";
    };
  };
}
