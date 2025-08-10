{lib, ...}: {
  # insane power savings
  services.tlp.enable = lib.mkDefault true;
}
