{
  lib,
  pkgs,
  ...
}: {
  services.k3s.manifests = let
    namespace = "cert-manager";
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
  };
}
