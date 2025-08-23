{
  config,
  ssot,
  pkgs,
  inputs,
  lib,
  ...
}: let
  wan-if = "enp2s0";
  lan-if = "wlo1";
in {
  environment.systemPackages = with pkgs; [iw lshw];

  age.secrets.loonster-pw = {
    rekeyFile = "${inputs.self}/secrets/loonster-pw.age";
  };

  # https://github.com/ghostbuster91/blogposts/blob/a2374f0039f8cdf4faddeaaa0347661ffc2ec7cf/router2023-part2/main.md
  # https://github.com/ghostbuster91/nixos-router/blob/fc164b8281943f01b21b582d8156b0753613dffd/modules/nixos/hostapd.nix#L20
  boot.kernel = {
    sysctl = {
      "net.ipv4.conf.all.forwarding" = true;

      # TODO: enable IPV6
      "net.ipv6.conf.all.forwarding" = false;
    };
  };

  systemd.network = {
    wait-online.anyInterface = true;
    networks = {
      # ethernet WAN side
      "10-enp2s0" = {
        matchConfig.name = wan-if;
        linkConfig.RequiredForOnline = "routable";
        networkConfig = {
          DHCP = "ipv4";
          DNSOverTLS = true;
          DNSSEC = true;
          IPv6PrivacyExtensions = false;
          IPv4Forwarding = true;
        };
      };

      # LAN side
      "30-wlo1" = {
        matchConfig.Name = lan-if;
        linkConfig.RequiredForOnline = "enslaved";
        networkConfig = {
          ConfigureWithoutCarrier = true;
          DHCP = "ipv4";
          DNSOverTLS = true;
        };
      };
    };
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;

    # No local firewall.
    nat.enable = false;
    firewall.enable = false;

    # TODO: https://github.com/thelegy/nixos-nftables-firewall
    nftables = {
      enable = true;
      ruleset = ''
        table inet filter {
          chain input {
            type filter hook input priority 0; policy drop;

            iifname { "${lan-if}" } accept comment "Allow local network to access the router"
            tcp dport 22 accept comment "Allow SSH - dual NAT so no WAN IP"
            iifname "${wan-if}" ct state { established, related } accept comment "Allow established traffic"
            iifname "${wan-if}" icmp type { echo-request, destination-unreachable, time-exceeded } counter accept comment "Allow select ICMP"
            iifname "${wan-if}" counter drop comment "Drop all other unsolicited traffic from wan"
            iifname "lo" accept comment "Accept everything from loopback interface"
          }
          chain forward {
            type filter hook forward priority filter; policy drop;

            iifname { "${lan-if}" } oifname { "${wan-if}" } accept comment "Allow trusted LAN to WAN"
            iifname { "${wan-if}" } oifname { "${lan-if}" } ct state { established, related } accept comment "Allow established back to LANs"
          }
        }

        table ip nat {
          chain postrouting {
            type nat hook postrouting priority 100; policy accept;
            oifname "${wan-if}" masquerade
          }
        }
      '';
    };
  };

  services.resolved.enable = false;
  services.dnsmasq = {
    enable = true;
    settings = {
      server = ["9.9.9.9" "8.8.8.8" "1.1.1.1"];
      domain-needed = true;
      bogus-priv = true;
      no-resolv = true;
      cache-size = 1000;

      # tmo home internet DHCP range is 192.168.12.xxx.
      # never collide or else demons will fly out your nose
      dhcp-range = ["${lan-if},192.168.10.50,192.168.10.254,24h"];
      interface = "${lan-if}";
      dhcp-host = "192.168.10.1";

      local = "/lan/";
      domain = "lan";
      expand-hosts = true;

      # don't advert hostname as localhost:)
      no-hosts = true;

      address = [
        #
        "/${ssot.cloudflare.domain}/${ssot.ips.riverwood}"
        "/${config.networking.hostName}.lan/192.168.10.1"
      ];
    };
  };

  # all these settings are from iw phys0 info.
  # https://github.com/morrownr/USB-WiFi/discussions/420 <-- has teh same device!
  # bro... 5GHz permanently disabled on this device because intel
  # https://superuser.com/questions/1645797/using-hostapd-on-ubuntu-20-04-to-create-5ghz-access-point-channel-153-primary
  # https://gist.github.com/iffa/290b1b83b17f51355c63a97df7c1cc60?permalink_comment_id=4584647#gistcomment-4584647 patches
  #
  # need to apply https://gist.github.com/iffa/290b1b83b17f51355c63a97df7c1cc60?permalink_comment_id=4584647#gistcomment-4584647
  # to the kernel, and then toggle the kernel flag.
  services.hostapd = {
    enable = true;
    package = pkgs.hostapd.overrideDerivation (old: {
      patches = lib.singleton (pkgs.fetchpatch
        {
          url = "https://tildearrow.org/storage/hostapd-2.10-lar.patch";
          sha256 = "USiHBZH5QcUJfZSxGoFwUefq3ARc4S/KliwUm8SqvoI=";
        });
    });

    radios = {
      # https://wiki.gentoo.org/wiki/Hostapd
      ${lan-if} = {
        band = "2g";
        countryCode = "US";

        # auto select channel
        channel = 13;
        settings = {
          hw_mode = "g"; # 2ghz
        };

        wifi4 = {
          enable = true;
          capabilities = [
            "HT40+"
            "SHORT-GI-20"
            "SHORT-GI-40"
          ];
        };

        networks = let
          ssid = "LoonsterBoonster9001";
        in {
          ${lan-if} = {
            inherit ssid;
            authentication = {
              mode = "wpa3-sae-transition";
              saePasswordsFile = config.age.secrets.loonster-pw.path;
              wpaPasswordFile = config.age.secrets.loonster-pw.path;
            };
          };
        };
      };
    };
  };
}
