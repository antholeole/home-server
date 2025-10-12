{
  lib,
  pkgs,
  config,
  ssot,
  ...
}: {
  services.k3s.manifests = let
    namespace = "kubernetes-reflector";
  in {
    reflector-namespace = lib.homeServer.kubernetes.mkNamespace namespace config;

    reflector = {
      enable = config.networking.hostName == ssot.k3sServer;

      content = lib.kubelib.fromHelm {
        inherit namespace;
        name = "reflector";
        chart = pkgs.helm-charts.emberstack.reflector;
      };
    };
  };
}
