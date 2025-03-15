{inputs, ...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    packages.cdk = pkgs.writeShellApplication {
      meta.description = "runs pulumi commands with decrypted secrets";
      name = "cdk";
      runtimeInputs = with pkgs; [
        pulumi
        pulumiPackages.pulumi-language-nodejs
        pnpm_10
        nodejs_23
      ];

      text = ''
        if [[ -z "''${FLAKE_ROOT}" ]]; then
          echo "this script should only be ran from inside the devshell"
          exit 1
        fi
      '';
    };
  };
}
