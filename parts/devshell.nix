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
      inputsFrom = [
        # Provides $FLAKE_ROOT in dev shell
        config.flake-root.devShell

        config.packages.cdk
      ];

      packages = with pkgs; [
        rage

        kubeseal
        (pkgs.writeShellApplication {
          name = "seal";
          runtimeInputs = with pkgs; [
            kubeseal
            moreutils # vipe
          ];

          text = ''
          if [ "$#" -lt 1 ]; then
              echo "Error: No arguments provided."
              echo "Usage: seal <secret name>"
              exit 1
          fi
            
          vipe -s yaml | kubeseal --cert ${inputs.self}/secrets/sealed-secrets-x509.crt > "$FLAKE_ROOT/cdk8s/src/sealed/$1.yaml"
          '';
        })

        nodejs_24
        nodePackages_latest.cdk8s-cli

        kubernetes-helm

        agsFull

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
