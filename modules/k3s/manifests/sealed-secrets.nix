{
  lib,
  pkgs,
  ssot,
  config,
  ...
}: {
  services.k3s.manifests = let
    namespace = "sealed-secrets";
  in {
    sealed-secrets-namespace = lib.homeServer.kubernetes.mkNamespace namespace config;

    sealed-secrets = {
      enable = config.networking.hostName == ssot.k3sServer;

      content = lib.kubelib.fromHelm {
        inherit namespace;

        name = "sealed-secrets";
        chart = pkgs.helm-charts.sealed-secrets.sealed-secrets;
      };
    };
  };
}
