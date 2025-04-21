#  import this to get everything required to make a system
{
  flake-config,
  inputs,
  ...
}: {
  imports = with flake-config.flake.modules.nixos; [
    ./tablet-hardware-config.nix

    ./modules/kde.nix

    inputs.nixos-hardware.nixosModules.microsoft-surface-go

    boilerplate
    disk-efi
  ];

  networking.hostName = "tablet";
  diskName = "/dev/sdb";
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAD9e26kcrBfe7Zho/WcUA3pVswKfCn1lgVK4i2RAxIs";
}
