{flake-config, ...}: {
  imports = with flake-config.flake.modules.nixos; [
    ./hardware-config.nix

    boilerplate
    disk-efi
  ];

  networking.hostName = "whiterun";
  diskName = "/dev/nvme0n1";
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBsbhWh/MGsZx5y9TX+gjeUV5J1Pn/I3nXu5vYXyP1cp";
}
