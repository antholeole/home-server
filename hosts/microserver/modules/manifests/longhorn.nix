{
  lib,
  pkgs,
  ...
}: {
  services.k3s.manifests = let
    namespace = "longhorn-system";
  in {
    longhorn-namespace = lib.homeServer.kubernetes.mkNamespace namespace;

    longhorn = {
      enable = true;
      content = lib.kubelib.fromHelm {
        inherit namespace;

        name = "longhorn";
        chart = pkgs.helm-charts.longhorn.longhorn;

        values = {
          service.ui = {
            type = "NodePort";
            # TODO get rid of this
            nodePort = 30001;
          };
        };
      };
    };

    main-storage-class = {
      enable = true;
      content = {
        kind = "StorageClass";
        apiVersion = "storage.k8s.io/v1";
        metadata.name = lib.homeServer.kubernetes.longhorn.storageClass.main;
        provisioner = "driver.longhorn.io";
        allowVolumeExpansion = true;

        parameters = {
          numberOfReplicas = "3";
          staleReplicaTimeout = "2880"; # 48h
          fromBackup = "";
          fsType = "ext4";
        };
      };
    };
  };
}
