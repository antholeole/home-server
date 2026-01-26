{
  inputs,
  ...
}: {
  perSystem = {
    config,
    pkgs,
    ssot,
    lib,
    ...
  }: {
    packages = let
      outputHashes = {
        kustomizes = "sha256-X6Ty/OSv8S6pbFZBFfPiFSCvwsFCt9dyxfxzhqxr/yY=";
        helm = "sha256-yiZrW1IFCazHQCctnFKFHibJ9lhUg/oynoIcLxq6BOg=";
        npm = "sha256-tVGK4LbnsJFjaKpGi3N53xbCQKB46YzYjmESf7F04sQ=";
      };

      manifestDependencies = let
        manifestFod = pkgs.stdenvNoCC.mkDerivation {
          name = "manifest-deps-fod";
          # do NOT use ${self} here. this causes the entire self
          # closure to be an input to the fod, causing frequent
          # rebuilds.
          src = ./kustomize;

          dontUnpack = true;

          nativeBuildInputs = [
            pkgs.kustomize
            pkgs.jq
            pkgs.bash
            pkgs.git
            pkgs.cacert
          ];

          buildPhase = ''
            mkdir $out

            # download every manifest
            jq -r 'to_entries[]  | "\(.key) \(.value)"' < $src/external-kustomize.json | xargs bash -c "kustomize localize \$1 $out/\$0 --no-verify"
          '';

          outputHashAlgo = "sha256";
          outputHashMode = "recursive";
          outputHash = outputHashes.kustomizes;
        };
      in
        pkgs.stdenvNoCC.mkDerivation {
          name = "manifest-deps";

          src = ./kustomize;
          dontUnpack = true;

          nativeBuildInputs = [
            pkgs.jq
          ];

          buildPhase = ''
            mkdir $out
            # TODO: config/default here doesn't make sense.
            jq "to_entries | map(.value = \"${manifestFod}/\" + .key + \"/config/default\") | from_entries" < $src/external-kustomize.json > $out/external-kustomize.json
          '';
        };

      manifestsRaw = pkgs.buildNpmPackage {
        pname = "home-server-cdk8s";
        version = "1.0.0";

        postPatch = ''
          cp ${manifestDependencies}/external-kustomize.json kustomize/external-kustomize.json
          cp -r ${inputs.secrets}/src/sealed src
        '';

        # don't rebuild the manifests if we're just iterating on this file.
        src = with lib.fileset;
          toSource {
            root = ./.;
            fileset = fileFilter (file: (! file.hasExt "nix")) ./.;
          };

        nativeBuildInputs = [
          pkgs.nodePackages_latest.cdk8s-cli

          (import ./helmcache {
            inherit pkgs;
            outputHash = outputHashes.helm;
          })

          pkgs.kubectl
          pkgs.git

          manifestDependencies
        ];

        npmDepsHash = outputHashes.npm;
        installPhase = ''
          mkdir -p $out/dist
          cp -r dist/ $out/
        '';
      };
      # FOD that fetches the kustomizes.
    in rec {
      manifests = let
        # the manifests pre kustomize.
        manifests = {
          # attrset of { <image>: <image with tag> }
          # e.g. { node: "node:21" }
          images,
        }:
          pkgs.stdenvNoCC.mkDerivation {
            name = "manifests";

            dontUnpack = true;

            nativeBuildInputs = [
              pkgs.kustomize
              manifestDependencies
            ];

            buildPhase = let
              kustomizeParam = lib.attrsets.mapAttrsToList (image: tagged: "${image}=${tagged} ") images;
            in ''
              mkdir -p $out/dist
              cp -r ${manifestsRaw}/dist $out
              cd $out/dist
              chmod +rw ./*
              kustomize edit set image ${lib.concatStrings kustomizeParam}
            '';
          };
      in
        lib.makeOverridable manifests {images = {};};

      manifests-example = manifests.override {
        images = {
          "tldraw/backend" = "leedleleedle:blah";
          redis = "redis:latest";
        };
      };
    };
  };
}
