{
  lib,
  pkgs,
  ssot,
  ...
}: let
  port = 3000;

  backend-fqdn = "draw-api.${ssot.cloudflare.domain}";

  tldraw-backend-pod = pkgs.nix-snapshotter.buildImage {
    name = "tldraw-backend";
    tag = "latest";
    resolvedByNix = true;
    config.entrypoint = ["${pkgs.tldraw-server}/bin/tldraw-server"];
  };

  tldraw-frontend-pod = let
    static-assets = pkgs.tldraw-web-client.overrideAttrs {
      VITE_SERVER_URL = backend-fqdn;
      VITE_SERVER_HTTPS = "true";
    };

    # this doesn't really follow nix convention - ideally you'd place this in /share but its easiest to
    # get working with caddy this way so we break the rules a little.
    caddyfile = pkgs.writeTextFile {
      name = "Caddyfile";
      destination = "/Caddyfile";
      text = ''
        :${builtins.toString port} {
          bind 0.0.0.0
          root * ${static-assets}
          try_files {path} /index.html
          file_server
        }
      '';
    };
  in
    pkgs.nix-snapshotter.buildImage {
      name = "tldraw-frontend";
      tag = "latest";
      resolvedByNix = true;
      config.entrypoint = [
        "${pkgs.caddy}/bin/caddy"
        "run"
        "--config"
        "${caddyfile}/Caddyfile"
      ];
    };
in {
  services.k3s.manifests = let
    namespace = "tldraw";
    app-backend = "tldraw-backend";
    app-frontend = "tldraw-frontend";
  in {
    tldraw-namespace = lib.homeServer.kubernetes.mkNamespace namespace;

    tldraw-frontend-service = {
      enable = true;
      target = "tldraw-frontend-service.yaml";

      content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          inherit namespace;
          name = "${app-frontend}-service";
        };

        spec = {
          selector.app = app-frontend;
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

    tldraw-frontend = {
      enable = true;
      target = "${app-frontend}.yaml";
      content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          inherit namespace;
          name = app-frontend;
          labels.app = app-frontend;
        };

        spec = {
          replicas = 1;
          selector.matchLabels.app = app-frontend;
          template = {
            metadata.labels.app = app-frontend;
            spec.containers = [
              {
                name = app-frontend;
                image = "nix:0${tldraw-frontend-pod}";
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

    tldraw-backend-service = {
      enable = true;
      target = "tldraw-backend-service.yaml";

      content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          inherit namespace;
          name = "${app-backend}-service";
        };

        spec = {
          selector.app = app-backend;
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
      target = "${app-backend}.yaml";

      content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          inherit namespace;

          name = app-backend;
          labels.app = app-backend;
        };
        spec = {
          replicas = 1;
          selector.matchLabels.app = app-backend;
          template = {
            metadata.labels.app = app-backend;
            spec.containers = [
              {
                name = app-backend;
                image = "nix:0${tldraw-backend-pod}";
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
            name = "${app-backend}-service";
            spec = {
              fqdn = backend-fqdn;
              protocol = "http";
            };
          }
          {
            name = "${app-frontend}-service";
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
          tldraw-backend-pod
          tldraw-frontend-pod
        ];
      }
    ];
  };
}
