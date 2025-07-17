{pkgs, ...}: {
  # a minimal dev environment, just in case we need to hack on the device.
  environment.systemPackages = with pkgs; [
    alacritty
    helix
    git
  ];
}
