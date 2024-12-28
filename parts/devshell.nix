{inputs, ...}: {
  perSystem = {
    system,
    pkgs,
    ...
  }: let
    server = (import "${inputs.self}/server") pkgs;
  in {
    devShells.default = pkgs.mkShell {
      inputsFrom = [
        server
      ];
    };
  };
}
