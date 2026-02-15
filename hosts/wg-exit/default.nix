{
  flake-config,
  ...
}: {
  imports = with flake-config.flake.modules.nixos; [
    core
    k3s
    ./disk.nix
    ./headscale.nix
    ./nginx.nix
    {config.facter.reportPath = ./facter.json;}
  ];

  services.k3s.role = "agent";
  # services.k3s.enable = lib.mkForce false;
  users.users.manager.hashedPassword = "!";
  networking.hostName = "wg-exit";
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBZxQl7sbNeSuG0fcyaOIOVgSEFimpDMcoUncb+BX2Gi";

  # ts times out all the time. pin to one build at a time to force it to not thrash too hard.
  nix.settings.max-jobs = 1;
  nix.settings.cores = 1;

  # TODO: one day this should be master
  k3s = {
    labels = [
      "type=vps"
    ];
    taints = [
      "type=vps:NoSchedule"
    ];
  };
}
