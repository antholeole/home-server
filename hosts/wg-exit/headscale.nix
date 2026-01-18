{
  ssot,
  config,
  inputs,
  ...
}: let
  subdomain = "offsite";
in {
  age.secrets.cf-headscale = {
    rekeyFile = "${inputs.self}/secrets/cf-headscale.age";
  };

  services.cloudflare-ddns = {
    enable = true;

    credentialsFile =
      config.age.secrets.cf-headscale.path;

    domains = [
      "${subdomain}.${ssot.cloudflare.domain}"
    ];
  };

  services.headscale = {
    enable = true;

    settings = {
      address = "0.0.0.0";
      dns = {
        base_domain = "${ssot.cloudflare.domain}";
        magic_dns = true;
      };
    };
  };
}
