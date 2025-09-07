{flake-config, ...}: {
  imports = with flake-config.flake.modules.nixos; [
    core
    wifi
    disk-efi
    
    {config.facter.reportPath = ./facter.json;}
  ];

  networking.hostName = "blackreach";
  diskName = "/dev/nvme0n1";
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEz65TROwu42p35hPLcgTiAXco4iQk9jCDiaxFoToGTs";
}
