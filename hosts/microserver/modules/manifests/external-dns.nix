{
  ssot,
  pkgs,
  lib,
  ...
}: {
  services.k3s.manifests = let
    namespace = "external-dns";
    cloudflare-secret-name = "cloudflare-secrets";
  in {
    external-dns-namespace = lib.homeServer.kubernetes.mkNamespace namespace;

    external-dns-cf-secrets = {
      enable = true;
      content = let
        metadata = {
          inherit namespace;
          name = cloudflare-secret-name;
        };
      in {
        inherit metadata;

        apiVersion = "bitnami.com/v1alpha1";
        kind = "SealedSecret";

        spec = {
          template.metadata = metadata;
          encryptedData = {
            CLOUDFLARE_API_TOKEN = lib.homeServer.sealed.secrets.external-dns.cloudflare-api-token;
          };
        };
      };
    };

    external-dns = {
      enable = true;
      content = lib.kubelib.fromHelm {
        inherit namespace;
        name = "external-dns";
        chart = pkgs.helm-charts.external-dns.external-dns;
        values = {
          logLevel = "debug";
          sources = ["ingress"];
          provider.name = "cloudflare";
          extraArgs = [
            "--source=ingress"
          ];
          env = [
            {
              name = "CF_API_TOKEN";
              valueFrom.secretKeyRef = {
                name = cloudflare-secret-name;
                key = "CLOUDFLARE_API_TOKEN";
              };
            }
          ];
        };
      };
    };
  };
}
