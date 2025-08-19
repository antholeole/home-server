{lib, ...}: {
  # insane power savings
  services.tlp.enable = lib.mkDefault true;
  # save interrupts under pressure. good for server.
  services.irqbalance.enable = lib.mkDefault true;

  time.timeZone = "America/Los_Angeles";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";

  # in systems with k3s, which enables systemd.networkd, this will conflict
  # with networkmanager but doesn't actually matter. disable the wait-online
  # so colmena does not yell at us.
  systemd.network.wait-online.enable = false;
}
