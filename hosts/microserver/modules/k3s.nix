{
  pkgs_24_11,
  ...
}: {
  imports = [
    ./manifests/sealed-secrets.nix
    ./manifests/kubernetes-dashboard.nix
    ./manifests/longhorn.nix
    ./manifests/cert-manager.nix
    ./manifests/ingress-nginx.nix

    ./flux.nix
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22 # ssh
      6443 # k3s api server

      443
      80
    ];
  };

  services.k3s = {
    enable = true;
    role = "server";
    package = pkgs_24_11.k3s_1_29;
    snapshotter = "nix";
    setKubeConfig = true;
    moreFlags = [
      # traefik is borderline incompatible with external
      # DNS. We'll install ingress nginx later.
      "--disable=traefik"
      "--disable=servicelb"
    ];
  };
}
