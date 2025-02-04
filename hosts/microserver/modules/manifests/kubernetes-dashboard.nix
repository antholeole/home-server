{
  lib,
  pkgs,
  ...
}: {
  services.k3s.manifests = let
    namespace = "kubernetes-dashboard";
  in {
    dashboard-namespace = {
      enable = true;
      content = {
        apiVersion = "v1";
        kind = "Namespace";
        metadata = {
          name = namespace;
          labels.name = namespace;
        };
      };
    };

    dashboard = {
      enable = true;
      content = lib.kubelib.fromHelm {
      inherit namespace;

        name = "kubernetes-dashboard";
        chart = pkgs.helm-charts.kubernetes.dashboard;
      };
    };
  };
}
