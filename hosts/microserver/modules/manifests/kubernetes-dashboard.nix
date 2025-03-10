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
      content = let
        yamls = lib.kubelib.fromHelm {
          inherit namespace;

          name = "kubernetes-dashboard";
          chart = pkgs.helm-charts.kubernetes.dashboard;
        };

        # https://github.com/kubernetes/dashboard/issues/9263
        add-namespace = yaml: lib.attrsets.recursiveUpdate yaml {metadata.namespace = namespace;};
        namespaced-yamls = builtins.map add-namespace yamls;
      in
        namespaced-yamls;
    };
  };
}
