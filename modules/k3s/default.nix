{pkgs,...}: {
  imports = [
    ./longhorn-support.nix
    ./flux.nix
    ./snapshotter.nix
    ./k3s.nix
  ];

  # bump open file limit
  security.pam.loginLimits = [
    { domain = "*"; type = "soft"; item = "nofile"; value = "65536"; }
    { domain = "*"; type = "hard"; item = "nofile"; value = "1048576"; }
  ];
  
  environment.systemPackages = with pkgs; [
    kubeseal
    nerdctl
    fluxcd
  ];
}
