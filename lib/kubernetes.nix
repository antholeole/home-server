{pkgs, ...}: {
  fromKustomize = name: kustomizePath: let
    buildKustomize = pkgs.runCommand name {} ''
      mkdir $out
      mkdir $out/lib

      ${pkgs.kustomize}/bin/kustomize build "${kustomizePath}" > "$out/lib/${name}.yaml"
    '';
  in "${buildKustomize}/lib/${name}.yaml";

  mkNamespace = namespace: {
    enable = true;
    content = {
      apiVersion = "v1";
      kind = "Namespace";
      metadata = {
        name = namespace;
        labels.name = namespace;
      };
    };
  };

  longhorn.storageClass.main = "longhorn-main";
  cloudflare.tunnelRef = {
    name = "k3s-cluster-tunnel";
    kind = "ClusterTunnel";
  };
}
