{
  lib,
  pkgs,
  ...
}: {
  services.k3s.manifests = let
    namespace = "vault";
  in {
    vault-namespace = lib.homeServer.kubernetes.mkNamespace namespace;

    vault = {
      enable = true;
      content = lib.kubelib.fromHelm {
        inherit namespace;

        name = "vault";
        chart = pkgs.helm-charts.hashicorp.vault;

        values = {
          server = {
            dataStorage = {
              enabled = true;
              size = "3Gi";
              storageClass = lib.homeServer.kubernetes.longhorn.storageClass.main;
            };
          };
          
          ui = {
            enabled = true;
            serviceType = "LoadBalancer";
            serviceNodePort = null;
            externalPort = 8200;
          };
        };
      };
    };
  };
}
