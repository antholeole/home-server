{lib,pkgs, ...}: {
  # a simple boot server that allows us to boot devices with
  # no usb drives (router!)
  services.pixiecore = {
    enable = lib.mkDefault false;
    debug = true;
    openFirewall = true;
    quick = "arch";
    dhcpNoBind = true;
  };

  environment.systemPackages = with pkgs; [
    pixiecore
  ];
}
