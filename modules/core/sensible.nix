{lib, ...}: {
  # insane power savings
  services.tlp.enable = lib.mkDefault true;

  time.timeZone = "America/Los_Angeles";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";
}
