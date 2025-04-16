{
  inputs,
  lib,
  ssot,
  ...
}: {
  services.k3s.manifests = let
    api-secret-name = "cloudflare-tunnel-secrets";
    namespace = "cloudflare-operator-system";
  in {
      cloudflare-operator = {
        enable = true;
        source = lib.homeServer.kubernetes.fromKustomize "cloudflare-operator" "${inputs.cloudflare-operator}/config/default";
      };

      cloudflare-tunnel-secrets = {
        enable = true;
        content = let
          metadata = {
            inherit namespace;
            name = api-secret-name;
          };
        in {
          inherit metadata;

          apiVersion = "bitnami.com/v1alpha1";
          kind = "SealedSecret";

          spec = {
            template.metadata = metadata;
            encryptedData = {
              CLOUDFLARE_API_KEY = lib.homeServer.sealed.secrets.cloudflare.api-key;
              CLOUDFLARE_API_TOKEN = lib.homeServer.sealed.secrets.cloudflare.api-token;
            };
          };
        };
      };

      tunnel = {
        enable = true;
        content = {
          apiVersion = "networking.cfargotunnel.com/v1alpha1";
          kind = lib.homeServer.kubernetes.cloudflare.tunnelRef.kind;
          metadata = {
            inherit namespace;

          name = lib.homeServer.kubernetes.cloudflare.tunnelRef.name;
          };
          spec = {
            newTunnel.name = "home-server-tunnel"; 
            size = 1; 

            cloudflare = {
              email = ""; 
              domain = ssot.cloudflare.domain; 
              secret = api-secret-name; 
              accountId = "e0d74c227439ece29e62209d109ae43e";
            };
          };
        };
      };
    };
}
