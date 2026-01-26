{
  pkgs,
  config,
  ...
}: let
  namespace = "flux-system";
  name = "manifest-registry";
  port = 80; # s3 needs to run on port 80 for flux to recognize
in {
  services.k3s.manifests = {
    namespace = {
      enable = config.services.k3s.role == "server";

      content = {
        apiVersion = "v1";
        kind = "Namespace";
        metadata = {
          name = namespace;
          labels.name = namespace;
        };
      };
    };

    flux = {
      enable = config.services.k3s.role == "server";

      source = let
        flux-manifests = pkgs.runCommand "flux-manifests" {} ''
          mkdir -p $out
          ${pkgs.fluxcd}/bin/flux install --export > $out/flux.yaml
        '';
      in "${flux-manifests}/flux.yaml";
    };

    flux-source = {
      enable = config.services.k3s.role == "server";

      content = {
        apiVersion = "source.toolkit.fluxcd.io/v1";
        kind = "Bucket";
        metadata = {
          inherit namespace;
          name = "caddy-bucket";
        };
        spec = {
          provider = "generic";
          interval = "30s"; # maybe too fast? idk.
          endpoint = "manifest-registry.flux-system.svc.cluster.local:${builtins.toString port}";
          insecure = true;
          bucketName = "dist";
        };
      };
    };

    flux-kustomize = {
      enable = config.services.k3s.role == "server";

      content = {
        apiVersion = "kustomize.toolkit.fluxcd.io/v1";
        kind = "Kustomization";
        metadata = {
          inherit namespace;
          name = "main";
        };

        spec = {
          interval = "02m0s";
          path = "./.";
          prune = true;

          retryInterval = "2m0s";
          sourceRef = {
            kind = "Bucket";
            name = "caddy-bucket";
          };
          timeout = "3m0s";
          wait = true;
        };
      };
    };

    manifest-registry = {
      # bug here and why we need to remove snapshotter.
      # Basically, for an image to exist on the node, it has to be in the store.
      # for the image to be in the store, it has to be used somewhere in its
      # derivation; so, if the control plane schedules a pod using an image
      # but the manifest does not exist on that node, the image will fail to
      # pull.
      #
      # two solutions:
      # 1. proxy store on a single node out to the cluster;
      # 2. don't use snapshotter for most images (very hard to remove it for the
      #    manifest serving images)
      enable = config.services.k3s.role == "server";

      content = {
        kind = "Deployment";
        apiVersion = "apps/v1";
        metadata = {
          inherit name namespace;
          labels = {
            app = name;
          };
        };
        spec = {
          replicas = 1;
          selector = {
            matchLabels = {
              app = name;
            };
          };
          template = {
            metadata = {
              labels = {
                app = name;
              };
            };
            spec = {
              containers = [
                {
                  inherit name;
                  image = config.services.zot.mkRef config.images.manifestStaticServe;
                  ports = [
                    {
                      containerPort = port;
                    }
                  ];
                }
              ];
            };
          };
        };
      };
    };

    manifest-registry-service = {
      enable = config.services.k3s.role == "server";

      content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "manifest-registry";
          namespace = "flux-system";
        };
        spec = {
          selector = {
            app = "manifest-registry";
          };
          ports = [
            {
              inherit port;
              targetPort = port;
            }
          ];
        };
      };
    };
  };
}
