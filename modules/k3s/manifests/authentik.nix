{
  lib,
  pkgs,
  config,
  ssot,
  ...
}: {
  services.k3s.manifests = let
    namespace = "authentik";
  in {
    authentik-namespace = lib.homeServer.kubernetes.mkNamespace namespace config;

    authentik = {
      enable = config.networking.hostName == ssot.k3sServer;

      content = lib.kubelib.fromHelm {
        inherit namespace;
        name = "authentik";
        chart = pkgs.helm-charts.authentik.authentik;

        values = let
          pgVolumeName = "postgres-creds";
          secretKeyVolumeName = "secret-key-volume";
          volumes = {
            volumeMounts = [
              {
                name = pgVolumeName;
                mountPath = "/${pgVolumeName}";
                readOnly = true;
              }
              {
                name = secretKeyVolumeName;
                mountPath = "/${secretKeyVolumeName}";
                readOnly = true;
              }
            ];

            volumes = [
              {
                name = pgVolumeName;
                secret.secretName = "pg-pass";
              }
              {
                name = secretKeyVolumeName;
                secret.secretName = "authentik-secret-key";
              }
            ];
          };
        in {
          server =
            volumes
            // {
              ingress = let
                domain = "authentik.${ssot.cloudflare.domain}";
              in {
                https = false;
                enabled = true;
                ingressClassName = "nginx";
                annotations = {
                  "nginx.ingress.kubernetes.io/ssl-redirect" = "true";
                  "cert-manager.io/cluster-issuer" = "cert-manager-cloudflare-issuer";
                };
                hosts = [
                  domain
                ];
                tls = [
                  {
                    hosts = [domain];
                    secretName = "authentik-tls-secret";
                  }
                ];
              };
            };
          worker = volumes;

          authentik = {
            secret_key = "file:///${secretKeyVolumeName}/SECRET";
            postgresql = {
              host = "cnpg-cluster-primary-rw.cnpgdb";
              user = "file:///${pgVolumeName}/username";
              password = "file:///${pgVolumeName}/password";
            };
          };
        };
      };
    };
  };
}
