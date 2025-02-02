{...}: {
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22 # ssh
      6443 # k3s api server
    ];
  };

  services.k3s = {
    enable = true;
    role = "server";
  };
}
