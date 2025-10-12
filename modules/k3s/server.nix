{
  pkgs,
  inputs,
  config,
  lib,
  ssot,
  ...
}: {
  imports = [
    ./manifests
  ];

  options.k3s.labels = lib.mkOption {
    description = "= seperated list of flags. e.g. disktype=ssd type=nas";
    default = [];
  };

  config = {
    # this also kind of sucks because it straight up fails if the k3s node is
    # not initalized yet but -\_()_/-
    systemd.services.k8s-sealed-secret-key = {
      enable =
        config.networking.hostName == ssot.k3sServer;

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

    services.k3s = lib.mkIf (config.networking.hostName == ssot.k3sServer) {
      role = "server";
      moreFlags =
        [
          # traefik is borderline incompatible with external
          # DNS. We'll install ingress nginx later.
          "--disable=traefik"
          "--disable=servicelb"
        ]
        ++ config.k3s.labels;
    };
  };
}
