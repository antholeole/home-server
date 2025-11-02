{
  config,
  inputs,
  ...
}: {    
  age.secrets.nm-secrets = {
    rekeyFile = "${inputs.self}/secrets/wifi-pass.age";
  };

  networking = {
    wireless.enable = false;
    networkmanager = {
      enable = true;

      # stablize mac since tmo doesn't like it
      wifi = {
        scanRandMacAddress = false;
        macAddress = "permanent";
      };

      
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
              psk = "$LOONSTER_PSK";
            };
          };
        };
      };
    };
  };
}
