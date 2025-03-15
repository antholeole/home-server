{
  pkgs,
  lib,
  ...
}: {
  services.k3s.manifests = {
    flux = {
      enable = true;
      content = lib.kubelib.fromHelm {
        chart = pkgs.helm-charts.fluxcd-community.flux2;
      };
    };
  };
}
