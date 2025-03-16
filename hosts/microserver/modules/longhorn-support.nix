# required to get longhorn working on nixOS.
{config,pkgs, ...}: {
  # longhorn looks for nsenter in specific paths, /usr/local/bin is one of
  # them so symlink the entire system/bin directory there.
  # https://github.com/longhorn/longhorn/issues/2166#issuecomment-1864656450
  systemd.tmpfiles.rules = ["L+ /usr/local/bin - - - - /run/current-system/sw/bin/"];

  environment.systemPackages = [
    pkgs.util-linux
  ];

  services.openiscsi = {
    enable = true;
    name = config.networking.hostName;
  };
}
