{self,...}: {
  perSystem = {
    config,
    pkgs,
    ssot,
    ...
  }: {
    packages.cdk8s = pkgs.buildNpmPackage (o: {
      pname = "home-server-cdk8s";
      version = "1.0.0";
      src = "${self}/cdk8s/";

      nativeBuildInputs = [
        pkgs.nodePackages_latest.cdk8s-cli
      ];

      npmDepsHash = "sha256-yrdT5YTcc8FoL6TlMdSZsqpreg06DSsQ4rhxIxKcfmM=";
      # makeCacheWritable = true;
      # dontNpmBuild = true;
      installPhase = ''
        cp -r dist/ $out
      '';
    });
  };
}
