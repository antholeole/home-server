{
  ssot,
  config,
  ...
}: let
  headscaleDomain = "headscale.${ssot.cloudflare.domain}";
in {
  networking.firewall.allowedTCPPorts = [80 443];
  services = {
    cloudflare-ddns = {
      enable = true;

      credentialsFile =
        config.age.secrets.cf-headscale.path;

      domains = [
        "*.${ssot.cloudflare.domain}"
      ];
    };

    nginx = let
      headscalePort = 444;
    in {
      enable = true;

      commonHttpConfig = ''
        set_real_ip_from 127.0.0.1;
        real_ip_header proxy_protocol;
      '';

      # we want:
      # - headscale.${domain} traffic to be forwarded to headscale
      # - everything else to be forwarded to the kubernetes cluster
      #
      # this means we need to preread the domain and proxy it that way.
      streamConfig = ''
        map $ssl_preread_server_name $backend_name {
                ${headscaleDomain}      headscale;
                default        cluster;
            }

        upstream headscale {
          server 127.0.0.1:${toString headscalePort}; 
        }

        upstream cluster {
          server 127.0.0.1:${toString ssot.ports.webSecurePort};
        }

        server {
          listen 443;
          proxy_pass $backend_name;
          ssl_preread on;
          proxy_protocol on;
        }
      '';

      virtualHosts.${headscaleDomain} = {
        onlySSL = true;
        useACMEHost = headscaleDomain;
        listen = [
          {
            addr = "127.0.0.1";
            port = headscalePort;
            ssl = true;
            proxyProtocol = true;
          }
        ];

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.headscale.port}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
