{
  config,
  inputs,
  ...
}: {
  # use the wifi password
  age.secrets.nm-secrets = {
    file = "${inputs.self}/secrets/wifi-pass.age";
    owner = "root";
    group = "root";
  };

  networking.networkmanager = {
    enable = true;
    ensureProfiles = {
      environmentFiles = [
        config.age.secrets.nm-secrets.path
      ];

      profiles = {
        loonster = {
          connection = {
            id = "LoonsterBoonster9000";
            type = "wifi";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "stable-privacy";
            method = "auto";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "LoonsterBoonster9000";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$LOONSTER_PWD";
          };
        };
      };
    };
  };
}
