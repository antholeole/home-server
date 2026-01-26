{config, ...}: {
  # don't preauth; k3s will do it for us
  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  systemd.services.k3s.path = [config.services.tailscale.package];
}
