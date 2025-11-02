{
  flake-config,
  ...
}: {
  imports = with flake-config.flake.modules.nixos; [
    core
    wifi
    disk-efi

    netboot

    k3s

    {config.facter.reportPath = ./facter.json;}
  ];

  services.pixiecore.enable = true;
  services.k3s = {
    role = "agent";
  };

  networking.hostName = "blackreach";
  diskName = "/dev/nvme0n1";
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEz65TROwu42p35hPLcgTiAXco4iQk9jCDiaxFoToGTs";

  k3s.labels = [
    "type=nas"
    "disktype=ssd"
  ];
}
