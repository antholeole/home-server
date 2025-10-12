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
        chart = pkgs.helm-charts.cloudnative-pg.cloudnative-pg;
      };
    };
  };
}
