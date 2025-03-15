{inputs, ...}: {
  agenix-shell = let
    secrets = import "${inputs.self}/secrets/secrets.nix";
  in {
    # each secret to be exposed to the shell should be added here.
    secrets = {
      cf-tunnel.file = "${inputs.self}/secrets/cf-tunnel-secret.age";
    };

    identityPaths = builtins.map (identity: identity.identity) secrets.masterIdentities;
  };

  perSystem = {
    system,
    pkgs,
    lib,
    inputs',
    config,
    ...
  }: {
    devShells.default = pkgs.mkShell {
       # Provides $FLAKE_ROOT in dev shell
      inputsFrom = [ config.flake-root.devShell ]; 
      
      packages = with pkgs; [
        kubectl
        kubeseal
        kubernetes-helm

        inputs'.colmena.packages.colmena
        inputs'.nixos-anywhere.packages.default

        config.packages.cdk
        config.agenix-rekey.package
      ];

      shellHook = ''
        git config --local blame.ignoreRevsFile .git-blame-ignore-revs
        source ${lib.getExe config.agenix-shell.installationScript}
      '';
    };
  };
}
