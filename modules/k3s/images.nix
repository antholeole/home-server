# TODO: split this up again
{
  lib,
  pkgs,
  ssot,
  config,
  ...
}: let
  port = 3000;

  backend-fqdn = "draw-api.${ssot.cloudflare.domain}";

  tldraw-backend-pod = pkgs.dockerTools.buildImage {
    copyToRoot = [pkgs.tldraw-server];
    name = "tldraw-backend";
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
    pkgs.dockerTools.buildImage {
      name = "tldraw-frontend";
      copyToRoot = [caddyfile pkgs.caddy static-assets];
      config.entrypoint = [
        "${pkgs.caddy}/bin/caddy"
        "run"
        "--config"
        "${caddyfile}/Caddyfile"
      ];
    };

  otherImages = {
    "tldraw/backend" = config.services.zot.mkRef tldraw-backend-pod;
    "tldraw/frontend" = config.services.zot.mkRef tldraw-frontend-pod;
  };

  manifests = pkgs.manifests.override {images = otherImages;};

  manifestStaticServe = pkgs.dockerTools.buildImage {
    name = "manifest-registry";
    copyToRoot = [manifests];
    config.entrypoint = [
      "${pkgs.rclone}/bin/rclone"
      "serve"
      "s3"
      "--addr"
      "0.0.0.0:80"
      "${manifests}"
    ];
  };
in {
  options = {
    images = lib.mkOption {
      readOnly = true;
      description = "all custom-built images.";
      default =
        otherImages
        // {
          inherit manifestStaticServe;
        };
    };
  };

  config.services = {
    zot = {
      enable = true;
      images = [
        tldraw-backend-pod
        tldraw-frontend-pod
        manifestStaticServe
      ];
    };
  };
}
