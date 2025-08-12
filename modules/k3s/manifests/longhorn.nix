{
  lib,
  pkgs,
  ...
}: {
  services.k3s.manifests = let
    namespace = "longhorn-system";
  in {
    longhorn-namespace = lib.homeServer.kubernetes.mkNamespace namespace;

    longhorn = {
      enable = true;
      content = lib.kubelib.fromHelm {
        inherit namespace;

        name = "longhorn";
        chart = pkgs.helm-charts.longhorn.longhorn;
      };
    };
  };
}
