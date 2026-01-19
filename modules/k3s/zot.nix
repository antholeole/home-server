{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  zot = with pkgs;
    buildGoModule rec {
      pname = "zot";
      version = "2.1.13";

      src = fetchFromGitHub {
        owner = "project-zot";
        repo = "zot";
        rev = "v${version}";
        hash = "sha256-1y2nkCAKXfqvxn3KkKUhTgRImm+RNqK42xFsRuYgw+0=";
      };

      vendorHash = "sha256-AY/efOaBQPDSDLrSaWL2xTFQn2IM6ZCQ+VNcXd3k58U=";

      # Build only the main zot binary
      subPackages = ["cmd/zot"];

      ldflags = [
        "-s"
        "-w"
        "-X zotregistry.io/zot/pkg/api/config.ReleaseTag=${version}"
        "-X zotregistry.io/zot/pkg/api/config.Commit=${src.rev}"
      ];

      # Skip tests during build (they require network and are extensive)
      doCheck = false;

      meta = with lib; {
        description = "A production-ready vendor-neutral OCI image registry";
        homepage = "https://zotregistry.io";
        license = licenses.asl20;
        maintainers = [];
        mainProgram = "zot";
      };
    };

  cfg = config.services.zot;
  imageDir =
    pkgs.runCommand "zot-images" {
      buildInputs = [pkgs.skopeo];
    } ''
      set -e

      mkdir -p $out

      export TMPDIR=$(mktemp -d)

      ${concatMapStringsSep "\n" (img: ''
          # Load the image tarball and copy to OCI layout
          # Extract image name and tag from the derivation
          IMAGE_TAR="${img}"
          IMAGE_NAME=$(basename ${img.imageName or "image"})
          IMAGE_TAG="${img.imageTag or "latest"}"

          echo "Processing $IMAGE_NAME:$IMAGE_TAG from $IMAGE_TAR"

          # Copy from docker-archive to OCI layout
          skopeo --insecure-policy --tmpdir $TMPDIR copy \
            docker-archive:$IMAGE_TAR \
            oci:$out/$IMAGE_NAME:$IMAGE_TAG
        '')
        cfg.images}
    '';

  # Zot configuration file
  zotConfig = pkgs.writeText "zot-config.json" (builtins.toJSON {
    distSpecVersion = "1.1.0";
    storage = {
      rootDirectory = "${imageDir}";
      dedupe = false;
      gc = false;
    };
    http = {
      address = "0.0.0.0";
      port = toString cfg.port;
    };
    log = {
      level = "info";
    };
  });
in {
  options.services.zot = {
    enable = mkEnableOption "Zot OCI registry";

    images = mkOption {
      type = types.listOf types.package;
      default = [];
      description = ''
        List of Docker images built with dockerTools.buildImage to serve.
        Each image should be a derivation created with pkgs.dockerTools.buildImage.
      '';
      example = literalExpression ''
        [
          (pkgs.dockerTools.buildImage {
            name = "myapp";
            tag = "latest";
            contents = [ pkgs.hello ];
          })
        ]
      '';
    };

    port = mkOption {
      type = types.port;
      default = 5000;
      description = "Port on which to run the zot registry";
    };

    mkRef = mkOption {
      type = types.functionTo types.str;
      readOnly = true;
      description = "Helper function to create image references: mkRef <image drv>";
    };

    package = mkOption {
      type = types.package;
      default = zot;
      defaultText = literalExpression "pkgs.zot";
      description = "The zot package to use";
    };
  };

  config = let
      registryUrl = "registry.local:${toString cfg.port}";
    in
    mkIf cfg.enable {
    services.zot.mkRef = container: "${registryUrl}/${container.imageName}:${container.imageTag}";

    environment.etc."rancher/k3s/registries.yaml".text = ''
      mirrors:
        "${registryUrl}":
          endpoint:
            - "http://127.0.0.1:${toString cfg.port}"
      configs:
        "${registryUrl}":
          tls:
            insecure_skip_verify: true
    '';

    systemd.services.zot = {
      description = "Zot OCI Registry";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/zot serve ${zotConfig}";
        Restart = "always";
        RestartSec = "10s";

        # Security hardening
        DynamicUser = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectHostname = true;
        ProtectClock = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        MemoryDenyWriteExecute = true;
        SystemCallArchitectures = "native";
      };
    };
  };
}
