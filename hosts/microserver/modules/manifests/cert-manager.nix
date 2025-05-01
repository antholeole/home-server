{
  lib,
  pkgs,
  ...
}: {
  services.k3s.manifests = let
    namespace = "cert-manager";
    api-secret = {
      name = "cloudflare-api-token-secret";
      key = "api-token";
    };
  in {
    cert-manager-namespace = lib.homeServer.kubernetes.mkNamespace namespace;

    cert-manager = {
      enable = true;
      content = lib.kubelib.fromHelm {
        inherit namespace;

        name = "cert-manager";
        chart = pkgs.helm-charts.jetstack.cert-manager;
        values = {
          crds.enabled = true;
        };
      };
    };

    cloudflare-dns-secret-sealed = let
      metadata = {
        inherit namespace;

        name = api-secret.name;
      };
    in {
      enable = true;
      content = {
        inherit metadata;

        apiVersion = "bitnami.com/v1alpha1";
        kind = "SealedSecret";

        spec = {
          template = {
            metadata = metadata;
            type = "opaque";
          };

          encryptedData.${api-secret.key} = lib.homeServer.sealed.secrets.cert-manager.cloudflare-dns;
        };
      };
    };

    cloudflare-issuer = {
      enable = true;
      content = {
        apiVersion = "cert-manager.io/v1";
        kind = "ClusterIssuer";
        metadata = {
          inherit namespace;
          name = "cf-issuer";
        };

        spec = {
          acme = {
            server = "https://acme-v02.api.letsencrypt.org/directory";
            privateKeySecretRef.name = "cluster-issuer-account-key";
            solvers = [
              {
                dns01.cloudflare.apiTokenSecretRef = api-secret;
              }
            ];
          };
        };
      };
    };
  };
}
