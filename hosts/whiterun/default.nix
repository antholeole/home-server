{flake-config, ...}: {
  imports = with flake-config.flake.modules.nixos; [
    core
    disk-efi

    ./router.nix

    {config.facter.reportPath = ./facter.json;}
  ];

  networking.hostName = "whiterun";
  diskName = "/dev/nvme0n1";
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9v7Tjn4O+cCLp9Gf/uRDhrMJvfNIBhG/C5nPXF84xt";
}
