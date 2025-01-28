#  import this to get everything required to make a system
{
  flake-config,
  inputs,
  ...
}: {
  imports = with flake-config.flake.modules.nixos; [
    ./tablet-hardware-config.nix

    inputs.nixos-hardware.nixosModules.microsoft-surface-go

    boilerplate
    disk-efi
  ];

  networking.hostName = "tablet";
  diskName = "/dev/sdb";
}
