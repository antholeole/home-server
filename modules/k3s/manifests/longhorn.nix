{
  lib,
  pkgs,
  config,
  ssot,
  ...
}: {
  services.k3s.manifests = let
    namespace = "longhorn-system";
  in {
    longhorn-namespace = lib.homeServer.kubernetes.mkNamespace namespace config;

    longhorn = {
    enable = config.services.k3s.role == "server";

      content = lib.kubelib.fromHelm {
        inherit namespace;
        name = "longhorn";
        chart = pkgs.helm-charts.longhorn.longhorn;
      };
    };
  };
}
