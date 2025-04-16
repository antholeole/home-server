{
  lib,
  pkgs,
  ssot,
  ...
}: let
  tldraw-backend = pkgs.nix-snapshotter.buildImage {
    name = "tldraw-backend";
    tag = "latest";
    resolvedByNix = true;
    config.entrypoint = ["${pkgs.tldraw-server}/bin/tldraw-server"];
  };
in {
  services.k3s.manifests = let
    namespace = "tldraw";
    app = "tldraw-backend";
    port = 3000;
    service-name = "tldraw-service";
  in {
    tldraw-namespace = lib.homeServer.kubernetes.mkNamespace namespace;

    tldraw-service = {
      enable = true;
      target = "tldraw-service.yaml";

      content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          inherit namespace;
          name = service-name;
        };

        spec = {
          selector.app = app;
          ports = [
            {
              port = 80;
              targetPort = port;
              protocol = "TCP";
            }
          ];
        };
      };
    };

    tldraw-backend = {
      enable = true;
      target = "${app}.yaml";

      content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          inherit namespace;

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
                    containerPort = port;
                  }
                ];
                env = [
                  {
                    name = "PORT";
                    value = builtins.toString port;
                  }
                  {
                    name = "HOSTNAME";
                    value = "0.0.0.0";
                  }
                ];
              }
            ];
          };
        };
      };
    };

    tldraw-tunnel = {
      enable = true;

      content = {
        apiVersion = "networking.cfargotunnel.com/v1alpha1";
        kind = "TunnelBinding";
        metadata = {
          name = "tldraw-cluster-tunnel";
          inherit namespace;
        };

        subjects = [
          {
            name = service-name;
            spec = {
              fqdn = "draw.${ssot.cloudflare.domain}";
              protocol = "http";
            };
          }
        ];
        tunnelRef = lib.homeServer.kubernetes.cloudflare.tunnelRef;
      };
    };
  };

  services.preload-containerd = {
    enable = true;
    targets = [
      {
        archives = [
          tldraw-backend
        ];
      }
    ];
  };
}
