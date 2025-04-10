{
  lib,
  pkgs,
  ...
}: {
  services.k3s.manifests = let
    namespace = "tldraw";
  in {
    tldraw-namespace = lib.homeServer.kubernetes.mkNamespace namespace;

    tldraw-backend = let
      app = "tldraw-backend";

      tldraw-backend = pkgs.nix-snapshotter.buildImage {
        name = "tldraw-backend";
        resolvedByNix = true;
        config.entrypoint = ["${pkgs.tldraw-server}/bin/tldraw-server"];
      };
    in {
      enable = true;
      target = "${app}.yaml";

      content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = app;
          labels.app = app;
        };
        spec = {
          replicas = 1;
          selector.matchLabels.app = app;
          template = {
            metadata.labels.app = app;
            spec.containers = [
              {
                name = app;
                image = "nix:0${tldraw-backend}";
                ports = [
                  {
                    containerPort = 3000;
                  }
                ];
              }
            ];
          };
        };
      };
    };
  };
}
