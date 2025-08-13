{
  age-private-key-path = "/var/lib/private/id_ed25519";
  public-keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJtgDcuHdgd6/VRuBvKlJU57+bHZJ3UsJU02BYbtUaQ/"
  ];

  # TODO: get these through ddns
  ips = {
    hrothgar = "192.168.12.171";
    riverwood = "192.168.12.211";
    whiterun = "192.168.12.167";
  };

  cloudflare = {
    domain = "oleina.xyz";
    zone-id = "7e311cc771f6226b43e317fd23592846";
    account-id = "7e311cc771f6226b43e317fd23592846";
  };
}
