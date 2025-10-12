{
  lib,
  pkgs,
  config,
  ssot,
  ...
}: {
  services.k3s.manifests = let
    namespace = "cnpg-system";
  in {
    cnpg-namespace = lib.homeServer.kubernetes.mkNamespace namespace config;

    cnpg = {
      enable = config.networking.hostName == ssot.k3sServer;

      content = lib.kubelib.fromHelm {
        inherit namespace;
        name = "cnpg";
        chart = pkgs.helm-charts.cloudnative-pg.cloudnative-pg;
      };
    };
  };
}
