{inputs, ...}: {
  perSystem = {
    system,
    pkgs,
    config,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      inputsFrom = [
        config.packages.server
        config.packages.client-app
      ];

      packages = with pkgs; [
        pkgs.cargo
      ];
    };
  };
}
