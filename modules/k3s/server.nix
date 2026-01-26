{
  pkgs,
  inputs,
  config,
  lib,
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
    age.secrets.
    k3s-vpn-auth.rekeyFile = "${inputs.self}/secrets/k3s-vpn-auth.age";

    # this also kind of sucks because it straight up fails if the k3s node is
    # not initalized yet but -\_()_/-
    systemd.services.k8s-sealed-secret-key = {
      enable =
        config.services.k3s.role == "server";

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

    services.k3s = {
      extraFlags =
        [
          # traefik is borderline incompatible with external
          # DNS. We'll install ingress nginx later.
          "--vpn-auth-file=${config.age.secrets.k3s-vpn-auth.path}"

          # let kubeconfig be readable by other users. I couldn't
          # figure out how to change its group to like a k3s group
          # so this is good enough
          "--write-kubeconfig-mode=\"0644\""
        ]
        ++ (
          if (config.services.k3s.role == "server")
          then [
            "--disable=traefik"
            "--disable=servicelb"
            "--flannel-ipv6-masq"
          ]
          else []
        )
        ++ builtins.map (label: "--node-label ${label}") config.k3s.labels;
    };

    systemd.services.k3s.restartTriggers = [
      config.environment.etc."rancher/k3s/registries.yaml".source
    ];
  };
}
