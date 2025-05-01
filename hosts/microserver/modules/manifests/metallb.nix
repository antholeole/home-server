{lib, pkgs, ...}: {
  services.k3s.manifests = {
    metallb = {
      enable = true;
      content = lib.kubelib.fromHelm {
        name = "metallb";
        chart = pkgs.helm-charts.metallb.metallb;

      };
    };
  };
}
