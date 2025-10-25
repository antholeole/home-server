{
  pkgs,
  outputHash,
}: let
  cache-helm = pkgs.stdenvNoCC.mkDerivation {
    name = "helm-deps-fod";
    src = ../cdk8s.yaml;

    dontUnpack = true;

    nativeBuildInputs = with pkgs; [
      kubernetes-helm
      moreutils
      yq
      jq
    ];

    buildPhase = ''
      mkdir $out

      NIX_DEBUG=7

      CACHE_DIR="$out/repocache"
      mkdir -p "$CACHE_DIR"


      REPLACE_JSON="$TMPDIR/replace.json"
      echo "{}" > "$REPLACE_JSON"

      export HELM_CACHE_HOME="$(mktemp -d)"
      export HELM_CONFIG_HOME="$(mktemp -d)"
      export HELM_DATA_HOME="$(mktemp -d)"

      CHART_LIST=$(yq -r '.imports[] | select(startswith("helm:")) | sub("^helm:"; "") | sub("@"; " ")' $src)
      while IFS=' ' read -r REPO_URL CHART_VERSION; do
          CHART_NAME=$(basename "$REPO_URL")
          REPO_NAME=$(echo "$REPO_URL" | sed -E 's/^(https?:\/\/[^\/]+\/.*)\/([^\/]+)$/\2/')
          TEMP_REPO_NAME="temp-$CHART_NAME-repo"
          helm repo add "$TEMP_REPO_NAME" "$(dirname "$REPO_URL")" 2>&1 | grep -v 'already exists'
          helm repo update
          helm pull "$TEMP_REPO_NAME/$CHART_NAME" \
                   --version "$CHART_VERSION" \
                   --destination "$CACHE_DIR" \
                   --untar=false

          # some repos pull weird; they say they're version x.y.z, and pull as vx.y.z.
          PULLED=$(ls $CACHE_DIR | grep "$CHART_NAME")

          helm repo remove "$TEMP_REPO_NAME"

          set -euxo pipefail
          cat "$REPLACE_JSON" | jq ". += {\"$REPO_URL\": \"$PULLED\"}" | sponge "$REPLACE_JSON"
      done <<< "$CHART_LIST"

      REPLACE_OUT="$out/replace.json"
      mv "$REPLACE_JSON" "$REPLACE_OUT"     
    '';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    inherit outputHash;
  };

  helm-template-replaced = pkgs.writeShellApplication {
    name = "helm";
    
    
    runtimeInputs = with pkgs; [
      jq
      kubernetes-helm
      python3
    ];
    
    text = ''
      python3 ${./helm-cache.py} "$@" --helm-cache ${cache-helm}
    '';
  };
in helm-template-replaced
