{
  ssot,
  lib,
  config,
  ...
}: {
  services.k3s = lib.mkIf (config.networking.hostName != ssot.k3sServer) {
    role = "agent";
    serverAddr = "https://${ssot.ips.riverwood}:6443";
  };
}
