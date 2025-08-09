{inputs, pkgs, config,...}: {
  home.packages = with pkgs; [
    hyprpaper
  ];

  wayland.windowManager.hyprland = {
    systemd.enable = true;
    package = pkgs.hyprland;
  };

  home.file.".config/hypr/hyprland.conf".text = let
    addToPath = [
      config.programs.ags.finalPackage

      inputs.ags.packages.${pkgs.system}.ags
    ];
  in
    with pkgs.hyprlandPlugins;
      ''
        plugin = ${hyprgrass}/lib/libhyprgrass.so
        plugin = ${hyprspace}/lib/libhyprspace.so

        env=PATH${builtins.concatStringsSep ":" addToPath}
      ''
      + builtins.readFile ./hypr.conf;

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
