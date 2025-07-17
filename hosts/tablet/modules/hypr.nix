{pkgs, ...}: {
  programs.niri.enable = true;
  
  # tmp until we can build a nice launcher that doesn't require keyboard
  environment.systemPackages = with pkgs; [fuzzel];
}
