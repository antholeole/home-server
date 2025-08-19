{...}: let
  wan-if = "enp2s0";
  lan-if = "wlo1";
in {
  # https://www.reddit.com/r/NixOS/comments/1hdjpsv/nixos_router/
  # https://github.com/ghostbuster91/blogposts/blob/a2374f0039f8cdf4faddeaaa0347661ffc2ec7cf/router2023-part2/main.md
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
            oifname "${lan-if}" masquerade
          }
        }
      '';
    };
  };
}
