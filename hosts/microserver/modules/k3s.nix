{...}: {
  imports = [
    ./manifests/sealed-secrets.nix
    ./manifests/kubernetes-dashboard.nix
    ./manifests/ingress-nginx.nix
    ./manifests/longhorn.nix
    ./manifests/cert-manager.nix
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
