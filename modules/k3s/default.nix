{
  pkgs,
  inputs,
  config,
  ...
}: {
  imports = [
    ./images.nix
    ./zot.nix
    
    ./longhorn-support.nix

    ./agent.nix
    ./server.nix
    ./tailscale.nix
  ];

  config = {
    # never timeout the apply, sometimes it takes forever.
    systemd.services.k3s.serviceConfig.TimeoutSec = 0;

    # bump open file limit
    security.pam.loginLimits = [
      {
        domain = "*";
        type = "soft";
        item = "nofile";
        value = "65536";
      }
      {
        domain = "*";
        type = "hard";
        item = "nofile";
        value = "1048576";
      }
    ];

    environment.systemPackages = with pkgs; [
      kubeseal
      nerdctl
      kubectl-cnpg
      fluxcd
    ];

    networking.firewall = {
      enable = true;

      allowedUDPPorts =[
        8472 # flannel CNI
      ];
      
      allowedTCPPorts = [
        22 # ssh
        6443 # k3s api server

        443
        80
      ];
    };

    age.secrets = {
      k3s-token = {
        rekeyFile = "${inputs.self}/secrets/k3s-token.age";
        generator.script = "alnum";
      };
      sealed-secrets-x509 = {
        rekeyFile = "${inputs.self}/secrets/sealed-secrets-x509.age";
        generator.script = "x509-priv";
      };
    };

    services.k3s = {
      enable = true;
      tokenFile = config.age.secrets.k3s-token.path;
    };
  };
}
