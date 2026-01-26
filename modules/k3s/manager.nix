{inputs, ...}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  home-manager.users.manager = {config, ...}: {
    home.stateVersion = "25.11";
    home.file.".kube/config".source =
      config.lib.file.mkOutOfStoreSymlink
      "/etc/rancher/k3s/k3s.yaml";
  };
}
