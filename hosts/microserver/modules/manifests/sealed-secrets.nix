{
  lib,
  pkgs,
  ...
}: {
  services.k3s.manifests = let
    namespace = "sealed-secrets";
  in {
    sealed-secrets-namespace = lib.homeServer.kubernetes.mkNamespace namespace;
    
    sealed-secrets = {
      enable = true;
      content = lib.kubelib.fromHelm {
        inherit namespace;

        name = "sealed-secrets";
        chart = pkgs.helm-charts.sealed-secrets.sealed-secrets;
      };
    };
  };
}
