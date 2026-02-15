{config, ...}: {
  # don't preauth; k3s will do it for us
  services.tailscale = {
    enable = true;
    extraUpFlags =
      ["--accept-routes"]
      ++ (
        if config.services.k3s.role == "agent"
        then []
        else [
          "--advertise-routes=10.42.0.0/16"
        ]
      );
  };

  networking.firewall.trustedInterfaces = ["tailscale0"];
  systemd.services.k3s.path = [config.services.tailscale.package];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };
}
