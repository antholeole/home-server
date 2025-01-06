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
      ];

      packages = with pkgs; [
      ];
    };
  };
}
