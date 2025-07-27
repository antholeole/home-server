{
  inputs,
  pkgs,
  ...
}: let
  astalDeps = with inputs.astal.packages.${pkgs.system}; [
    astal4
    battery
  ];
in {
  imports = [inputs.ags.homeManagerModules.default];

  home.packages = astalDeps ++ [
    pkgs.watchexec
    pkgs.nerd-fonts.symbols-only
    pkgs.inter-nerdfont
  ];

  programs.ags = {
    enable = true;
    systemd = {
      enable = true;
      defines = {
        DEV = "undefined";
      };
    };

    configDir = ./.;    
    extraPackages = astalDeps ++ [
      inputs.astal.packages.${pkgs.system}.astal4
      pkgs.hyprland
    ];
  };
}
