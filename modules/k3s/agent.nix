{
  ssot,
  lib,
  config,
  ...
}: {
  services.k3s = lib.mkIf (config.services.k3s.role == "agent") {
    serverAddr = "https://${ssot.k3sServer}.oleina:6443";
  };
}
