{
  pkgs,
  inputs,
  ...
}: {
  services.proxmox-ve = {
    enable = true;
    ipAddress = "192.168.0.1";
  };
}
