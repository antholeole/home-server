{inputs, ...}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages.host-image = inputs.nixos-generators {
      system = system;
      specialArgs = {
        pkgs = pkgs;
      };
      modules = [
        {
          nix.registry.nixpkgs.flake = nixpkgs;
          virtualisation.diskSize = 30 * 1024;
        }
      ];
      format = "linode";
    };
  };
}
