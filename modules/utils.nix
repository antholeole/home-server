{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    bottom
    vim
  ];
}
