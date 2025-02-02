{...}: {
  perSystem = {
    system,
    pkgs,
    lib,
    inputs',
    config,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        libisoburn
        kubectl

        inputs'.colmena.packages.colmena
        inputs'.nixos-anywhere.packages.default

        config.agenix-rekey.package
      ];

      shellHook = ''
       git config --local blame.ignoreRevsFile .git-blame-ignore-revs
      '';
    };
  };
}
