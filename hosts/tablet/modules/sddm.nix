{
  pkgs,
  ...
}: {
  environment.systemPackages = [
    pkgs.maliit-keyboard
  ];
    
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    settings = {
      General.InputMethod = pkgs.maliit-keyboard.pname;
    };
  };
}
