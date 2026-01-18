{flake-config, ...}: {
  imports = with flake-config.flake.modules.nixos; [
    core
    # k3s this server is far too small to run k3s
    ./disk.nix
    ./headscale.nix
    {config.facter.reportPath = ./facter.json;}
  ];

  services.k3s.role = "agent";
  users.users.manager.hashedPassword = "!";
  networking.hostName = "wg-exit";
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBZxQl7sbNeSuG0fcyaOIOVgSEFimpDMcoUncb+BX2Gi";

  # ts times out all the time. pin to one build at a time to force it to not thrash too hard.
  nix.settings.max-jobs = 1;
  nix.settings.cores = 1;
}
