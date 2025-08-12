{inputs, ...}: {
  imports = [inputs.nix-snapshotter.nixosModules.default];

  virtualisation.containerd = {
    enable = true;
    nixSnapshotterIntegration = true;
    k3sIntegration = true;
  };

  services.nix-snapshotter = {
    enable = true;
  };
}
