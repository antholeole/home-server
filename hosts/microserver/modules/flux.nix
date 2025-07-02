{
  pkgs,
  ssot,
  ...
}: let
  images = import ./images pkgs ssot;

  namespace = "flux-system";
  name = "manifest-registry";
  port = 80; # s3 needs to run on port 80 for flux to recognize

  manifests = pkgs.manifests.override {inherit images;};

  manifestStaticServe = pkgs.nix-snapshotter.buildImage {
    inherit name;
    tag = "latest";
    resolvedByNix = true;
    config.entrypoint = [
      "${pkgs.rclone}/bin/rclone"
      "serve"
      "s3"
      "--addr"
      "0.0.0.0:${builtins.toString port}"
      "${manifests}"
    ];
  };
in {
  services.k3s.manifests = {
    namespace = {
      enable = true;
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
      enable = true;
      source = let
        flux-manifests = pkgs.runCommand "flux-manifests" {} ''
          mkdir -p $out
          ${pkgs.fluxcd}/bin/flux install --export > $out/flux.yaml
        '';
      in "${flux-manifests}/flux.yaml";
    };

    flux-source = {
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
      enable = true;
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
                  image = "nix:0${manifestStaticServe}";
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
      enable = true;
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

  services.preload-containerd = {
    targets =
      (builtins.attrValues images)
      ++ [
        manifestStaticServe
      ];
  };
}
