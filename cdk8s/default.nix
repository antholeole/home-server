{
  self,
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
      manifestDependencies = let
        manifestFod = pkgs.stdenvNoCC.mkDerivation {
          name = "manifest-deps-fod";
          src = "${self}/cdk8s/kustomize";

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
          outputHash = "sha256-X6Ty/OSv8S6pbFZBFfPiFSCvwsFCt9dyxfxzhqxr/yY=";
        };
      in
        pkgs.stdenvNoCC.mkDerivation {
          name = "manifest-deps";

          src = "${self}/cdk8s/kustomize";
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

          pkgs.kubectl
          
          pkgs.git

          manifestDependencies
        ];

        npmDepsHash = "sha256-L6IYe7uq7CzNU4s5sm6+n9GdPV74adeQXPjgTi3lSBE=";
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
          node = "node:21";
          redis = "redis:latest";
        };
      };
    };
  };
}
