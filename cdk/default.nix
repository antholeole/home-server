{...}: {
  perSystem = {
    config,
    pkgs,
    ssot,
    ...
  }: {
    packages.cdk = pkgs.writeShellApplication {
      meta.description = "runs pulumi commands with decrypted secrets";
      name = "cdk";
      runtimeInputs = with pkgs; [
        pulumi
        pulumiPackages.pulumi-language-nodejs
        nodejs_24
      ];

      text = ''
        if [[ -z "''${FLAKE_ROOT}" ]]; then
          echo "this script should only be ran from inside the devshell"
          exit 1
        fi

        export DOMAIN=${ssot.cloudflare.domain}
        export ZONE_ID=${ssot.cloudflare.zone-id}
        export ACCOUNT_ID=${ssot.cloudflare.account-id}

        cd "$FLAKE_ROOT/cdk" ; pulumi "$@"
      '';
    };
  };
}
