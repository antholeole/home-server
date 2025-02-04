{...}: {
  # some base, "always on", deployments.
  imports = [
    ./manifests/admin-role.nix
    ./manifests/sealed-secrets.nix
    ./manifests/kubernetes-dashboard.nix
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22 # ssh
      6443 # k3s api server
    ];
  };

  services.k3s = {
    enable = true;
    role = "server";
  };
}
