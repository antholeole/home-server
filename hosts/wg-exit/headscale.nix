{
  ssot,
  config,
  inputs,
  pkgs,
  ...
}: let
  subdomain = "headscale";
  domain = "${subdomain}.${ssot.cloudflare.domain}";
in {
  age.secrets = {
    cf-headscale.rekeyFile = "${inputs.self}/secrets/cf-headscale.age";

    headscale-oidc-secret = {
      rekeyFile = "${inputs.self}/secrets/headscale-oidc-secret.age";
      owner = config.services.headscale.user;
      group = config.services.headscale.group;
      mode = "600";
    };
  };

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

  services.headscale = {
    enable = true;

    settings = {
      address = "127.0.0.1";
      port = 8080;
      server_url = "https://${domain}";

      policy.path = let
        k3sGroup = "group:k3s-nodes";
      in
        pkgs.writeTextFile {
          name = "headscale-acl.hujson";
          text = builtins.toJSON {
            groups = {
              ${k3sGroup} = ["k3s@"];
            };
            autoApprovers = {
              routes = {
                "10.42.0.0/16" = [k3sGroup];
              };
            };

            acls = [
              {
                action = "accept";
                src = ["*"];
                dst = ["*:*"];
              }
            ];
          };
        };

      dns = {
        base_domain = "oleina"; # no .xyz tld since its resolved here. so like `hrothgar.oleina`
        magic_dns = true;
        nameservers.global = [
          "1.1.1.1"
          "1.0.0.1"
        ];
      };

      ip_prefixes = [
        "100.64.0.0/10"
      ];

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
}
