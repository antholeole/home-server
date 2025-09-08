{
  lib,
  pkgs,
  ssot,
  config,
  ...
}: {
  services.k3s.manifests = let
    namespace = "ingress-nginx"; # this is the default one by the file provided
  in {
    ingress-nginx-namespace = lib.homeServer.kubernetes.mkNamespace namespace config;

    ingress-nginx = {
      enable = config.networking.hostName == ssot.k3sServer;

      content = lib.kubelib.fromHelm {
        inherit namespace;

        name = "ingress-nginx";
        chart = pkgs.helm-charts.kubernetes-ingress-nginx.ingress-nginx;

        values = {
          # allow the ingress pods to read the cluster dns. this means that
          # we can use ingress nginx as a proxy between the world and the
          # internal services.
          controller = {
            dnsPolicy = "ClusterFirstWithHostNet";
            hostNetwork = true;
            kind = "DaemonSet";
          };
        };
      };
    };
  };
}
