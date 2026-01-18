{flake-config, ...}: {
  imports = with flake-config.flake.modules.nixos; [
    core
    k3s
    ./disk.nix
    ./headscale.nix
    {config.facter.reportPath = ./facter.json;}
  ];

  services.k3s.role = "agent";
  users.users.manager.hashedPassword = "";
  networking.hostName = "wg-exit";
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEy4Axxqe2US+WpRYz2tJx2ywVPpQj/hhR92VIKP2XQi";
}
