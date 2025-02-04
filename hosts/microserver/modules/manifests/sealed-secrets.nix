{
  lib,
  pkgs,
  ...
}: {
  services.k3s.manifests.sealed-secrets = {
    enable = true;
    content = lib.kubelib.fromHelm {
      name = "sealed-secrets";
      chart = pkgs.helm-charts.bitnami.sealed-secrets;
      namespace = "default";
    };
  };
}
