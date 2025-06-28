{self, ...}: {
  perSystem = {
    config,
    pkgs,
    ssot,
    lib,
    ...
  }: {
    packages = rec {
      manifests = let
        # the manifests pre kustomize.
        manifestsRaw = pkgs.buildNpmPackage (o: {
          pname = "home-server-cdk8s";
          version = "1.0.0";

          # don't rebuild the manifests if we're just iterating on this file.
          src = with lib.fileset;
            toSource {
              root = ./.;
              fileset = fileFilter (file: ! file.hasExt "nix") ./.;
            };

          nativeBuildInputs = [
            pkgs.nodePackages_latest.cdk8s-cli
          ];

          npmDepsHash = "sha256-2ifxpyhZ06sgX3Ac1YbjkeW2hNubihjQE9BSIioJIOc=";
          installPhase = ''
            mkdir -p $out/dist
            cp -r dist/ $out/
          '';
        });

        manifests = {
          # attrset of { <image>: <image with tag> }
          # e.g. { node: "node:21" }
          manifests,
        }:
          pkgs.stdenvNoCC.mkDerivation {
            name = "manifests";

            dontUnpack = true;

            nativeBuildInputs = [
              pkgs.kustomize
            ];

            buildPhase = let
              kustomizeParam = lib.attrsets.mapAttrsToList (image: tagged: "${image}=${tagged} ") manifests;
            in ''
              tmpdir=$(mktemp -d)

              # todo this is bad how do we do it right
              cp -r ${manifestsRaw}/dist $tmpdir/

              cd $tmpdir/dist
              chmod +rw ./*

              kustomize edit set image ${lib.concatStrings kustomizeParam}
              mkdir -p $out/
              kustomize build $tmpdir/dist -o $out/
            '';
          };
      in
        lib.makeOverridable manifests {manifests = {};};

      manifests-example = manifests.override {
        manifests = {
          node = "node:21";
          redis = "redis:latest";
        };
      };
    };
  };
}
