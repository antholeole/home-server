pkgs: ssot: let
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
  "tldraw/backend" = tldraw-backend-pod;
  "tldraw/frontend" = tldraw-frontend-pod;
}
