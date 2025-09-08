{
  lib,
  pkgs,
  ssot,
  config,
  ...
}: {
  services.k3s.manifests = let
    namespace = "cert-manager";
  in {
    cert-manager-namespace = lib.homeServer.kubernetes.mkNamespace namespace config;

    cert-manager = {
      enable = config.networking.hostName == ssot.k3sServer;

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
