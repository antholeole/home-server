{pkgs_24_11, config, inputs, ssot, ...}: {
  imports = [
    ./manifests/sealed-secrets.nix
    ./manifests/kubernetes-dashboard.nix
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

  age.secrets.k3s-token = {
    rekeyFile = "${inputs.self}/secrets/k3s-token.age";
    generator.script = "alnum";
  };

  # don't timeout on boot. the node we run it on in smalllll so it takes
  # like 5 mins to get everything going.
  systemd.services.k3s.serviceConfig.TimeoutSec = 0;

  services.k3s = {
    enable = true;
    role = "server";
    package = pkgs_24_11.k3s_1_29;
    snapshotter = "nix";

    tokenFile = config.age.secrets.k3s-token.path;
    serverAddr = "https://${ssot.ips.riverwood}:6443";
    
    setKubeConfig = true;
    moreFlags = [
      # traefik is borderline incompatible with external
      # DNS. We'll install ingress nginx later.
      "--disable=traefik"
      "--disable=servicelb"
    ];
  };
}
