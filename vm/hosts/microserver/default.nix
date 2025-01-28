#  import this to get everything required to make a system
{flake-config, ...}: {
  imports = with flake-config.flake.modules.nixos; [
    ./hardware-config.nix

    boilerplate
    disk-efi
  ];

  networking.hostName = "microserver";
  diskName = "/dev/nvme0n1";
}
