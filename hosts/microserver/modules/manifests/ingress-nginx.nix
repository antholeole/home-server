{
  lib,
  pkgs,
  ...
}: {
  services.k3s.manifests = let
    namespace = "nginx-system";
  in {
    nginx-namespace = lib.homeServer.kubernetes.mkNamespace namespace;

    ingress-nginx = {
      enable = true;
      content = lib.kubelib.fromHelm {
        inherit namespace;

        name = "ingress-nginx";
        chart = pkgs.helm-charts.kubernetes-ingress-nginx.ingress-nginx;
      };
    };
  };
}
