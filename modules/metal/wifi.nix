{
  config,
  inputs,
  ssot,
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

        profiles = let
          mkLoonster = ssid: priority: {
            connection = {
              id = ssid;
              type = "wifi";
              autoconnect-priority = builtins.toString priority;
            };
            ipv4 = {
              method = "auto";
            };
            ipv6 = {
              addr-gen-mode = "stable-privacy";
              method = "auto";
            };
            wifi = {
              inherit ssid;
              mode = "infrastructure";
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "$LOONSTER_PSK";
            };
          };
        in {
          loonster9000 = mkLoonster "LoonsterBoonster9000" 1;

          # prioritize our custom built wifi.
          loonster9001 = mkLoonster ssot.wifi.ssid 2;
        };
      };
    };
  };
}
