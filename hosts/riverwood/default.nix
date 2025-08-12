#  import this to get everything required to make a system
{
  flake-config,
  ...
}: {
  imports = with flake-config.flake.modules.nixos; [
    core
    k3s
    wifi
    disk-efi
  ];


  # first node.
  services.k3s.clusterInit = true;

  networking.hostName = "riverwood";
  diskName = "/dev/nvme0n1";
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAD9e26kcrBfe7Zho/WcUA3pVswKfCn1lgVK4i2RAxIs";
}
