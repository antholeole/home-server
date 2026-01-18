{
  ssot,
  config,
  inputs,
  ...
}: let
  subdomain = "offsite";
  domain = "${subdomain}.${ssot.cloudflare.domain}";
in {
  security.acme = {
    acceptTerms = true;
    certs = {
      ${domain} = {
        email = "oleina@${ssot.cloudflare.domain}";
        group = "nginx";
        dnsProvider = "cloudflare";
        environmentFile = config.age.secrets.cf-headscale.path;
      };
    };
  };

  age.secrets = {
    cf-headscale.rekeyFile = "${inputs.self}/secrets/cf-headscale.age";

    headscale-oidc-secret = {
      rekeyFile = "${inputs.self}/secrets/headscale-oidc-secret.age";
      owner = config.services.headscale.user;
      group = config.services.headscale.group;
      mode = "600";
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];

  services = {
    nginx = {
      enable = true;
      virtualHosts.${domain} = {
        forceSSL = true;
        useACMEHost = domain;

        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.headscale.port}";
          proxyWebsockets = true;
        };
      };
    };

    headscale = {
      enable = true;

      settings = {
        address = "127.0.0.1";
        port = 8080;
        server_url = "https://${domain}";
        dns = {
          base_domain = "oleina"; # no .xyz tld since its resolved here. so like `hrothgar.oleina`
          magic_dns = true;
          nameservers.global = [
            "1.1.1.1"
            "1.0.0.1"
          ];
        };

        oidc = {
          # solves a chicken and egg problem. The K3 network requires this
          # instance to be up and running, but if we block on the k3s network
          # we deadlock.
          only_start_if_oidc_is_available = false;

          issuer = "https://authentik.${ssot.cloudflare.domain}/application/o/headscale/";
          client_id = "EY5wQGR9WvPiA4DBtZHq4bpGILrFceOaR5ppcQ9v";
          scope = ["openid" "profile" "email" "custom"];
          client_secret_path = config.age.secrets.headscale-oidc-secret.path;
          pkce = {
            enabled = true;
            method = "S256";
          };
        };
      };
    };
  };
}
