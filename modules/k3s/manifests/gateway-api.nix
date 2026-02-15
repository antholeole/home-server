{
  pkgs,
  config,
  ...
}: {
  services.k3s.manifests.gateway-api = {
    enable = config.services.k3s.role == "server";

    source = pkgs.fetchurl {
      url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.1/standard-install.yaml";
      sha256 = "sha256-c7kbd/a+AjqMkslp/GZOW9OxoorqWerJ68kEYHNU2tI=";
    };
  };
}
