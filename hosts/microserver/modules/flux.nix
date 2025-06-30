{
  pkgs,
  ssot,
  ...
}: let
  images = import ./images pkgs ssot;

  manifestStaticServe = let
    manifests = pkgs.manifests.override {inherit images;};
  in
    pkgs.nix-snapshotter.buildImage {
      name = "manifest-oci-registry";
      tag = "latest";
      resolvedByNix = true;
      config.entrypoint = [
        "${pkgs.caddy}/bin/caddy"
        "file-server"
        "--listen"
        "0.0.0.0:2015"
        "--root"
        "${manifests}"
      ];
    };
in {
  services.preload-containerd = {
    targets =
      (builtins.attrValues images)
      ++ [
        manifestStaticServe
      ];
  };
}
