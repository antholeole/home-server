{
  pkgs,
  pkgs_24_11,
  config,
  inputs,
  ...
}: {
  imports = [
    # ./manifests/ingress-nginx.nix
    ./manifests/cert-manager.nix
    ./manifests/sealed-secrets.nix

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

  systemd.services.k8s-sealed-secret-key = {
    description = "Deploy Sealed Secrets TLS Key to Kubernetes";
    after = ["k3s.service"];
    requires = ["k3s.service"];
    wantedBy = ["multi-user.target"];
    path = with pkgs; [kubectl coreutils];
    script = ''
      export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

      # this namespace may or may not exist yet.
      kubectl apply -f - <<EOF
      apiVersion: v1
      kind: Namespace
      metadata:
        name: sealed-secrets
      EOF

      kubectl apply -f - <<EOF
      apiVersion: v1
      kind: Secret
      metadata:
        name: secret-tls-keys
        namespace: sealed-secrets
        labels:
          sealedsecrets.bitnami.com/sealed-secrets-key: active
      type: kubernetes.io/tls
      data:
        tls.crt: $(base64 -w 0 ${inputs.self}/secrets/sealed-secrets-x509.crt)
        tls.key: $(base64 -w 0 ${config.age.secrets.sealed-secrets-x509.path})
      EOF
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
      Group = "root";
    };
  };

  age.secrets = {
    k3s-token = {
      rekeyFile = "${inputs.self}/secrets/k3s-token.age";
      generator.script = "alnum";
    };
    sealed-secrets-x509 = {
      rekeyFile = "${inputs.self}/secrets/sealed-secrets-x509.age";
      generator.script = "x509-priv";
    };
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
    # serverAddr = "https://${ssot.ips.riverwood}:6443";

    setKubeConfig = true;
    moreFlags = [
      # traefik is borderline incompatible with external
      # DNS. We'll install ingress nginx later.
      "--disable=traefik"
      "--disable=servicelb"
    ];
  };
}
