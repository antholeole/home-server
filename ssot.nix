{
  age-private-key-path = "/var/lib/private/id_ed25519";
  public-keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJtgDcuHdgd6/VRuBvKlJU57+bHZJ3UsJU02BYbtUaQ/"
  ];

  ips = {
    hrothgar = "hrothgar.lan"; # tablet, sees the world
    riverwood = "192.168.12.123"; # first node; IP so we can for now point a dns record in dnsmasq
    whiterun = "192.168.12.97"; # router. central to everything
    # NAS = blackreach. Big AF and you can never find anything
  };

  cloudflare = {
    domain = "oleina.xyz";
    zone-id = "7e311cc771f6226b43e317fd23592846";
    account-id = "7e311cc771f6226b43e317fd23592846";
  };
}
