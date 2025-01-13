{inputs, ...}: {
  perSystem = {
    pkgs,
    lib,
    system,
    ...
  }: {
    packages.host-image = inputs.nixos-generators.nixosGenerate {
      inherit system;
      specialArgs = {
        pkgs = pkgs;
      };
      modules = [
        inputs.proxmox-nixos.nixosModules.proxmox-ve

        ./proxmox.nix
        ./snapshotter.nix

        ({...}: {
          nix.registry.nixpkgs.flake = inputs.nixpkgs;
          virtualisation.diskSize = 30 * 1024;
          system.stateVersion = "25.05";
          nixpkgs.overlays = [
            inputs.proxmox-nixos.overlays.${system}
          ];
        })
      ];
      format = "linode";
    };
  };
}
