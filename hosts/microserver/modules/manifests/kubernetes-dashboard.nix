{
  lib,
  pkgs,
  ...
}: {
  services.k3s.manifests = let
    namespace = "kubernetes-dashboard";
    admin-account-name = "dashboard-admin";
  in {
    dashboard-namespace = lib.homeServer.kubernetes.mkNamespace namespace;

    dashboard = {
      enable = true;
      content = let
        yamls = lib.kubelib.fromHelm {
          inherit namespace;

          name = "kubernetes-dashboard";
          chart = pkgs.helm-charts.kubernetes.dashboard;

          values = {
            # fix for https://github.com/Kong/kong/issues/13730
            kong.image.tag = "3.8";
          };
        };

        # https://github.com/kubernetes/dashboard/issues/9263
        add-namespace = yaml: lib.attrsets.recursiveUpdate yaml {metadata.namespace = namespace;};
        namespaced-yamls = builtins.map add-namespace yamls;
      in
        namespaced-yamls;
    };

    "${admin-account-name}" = {
      enable = true;
      target = "${admin-account-name}.serviceaccount.yaml";
      content = {
        apiVersion = "v1";
        kind = "ServiceAccount";
        metadata = {
          inherit namespace;

          name = admin-account-name;
        };
      };
    };

    # TODO: we may be able to use sealed secrets to keep this hermetic;
    # 1. store a sealed secrets private key into a age key
    # 2. inject that pk as a oneshot service into the k3s manifest dir
    # 3. use a sealed secret instead of letting the value be created at runtime.
    "${admin-account-name}.secret" = {
      enable = true;
      target = "${admin-account-name}.secret.yaml";
      content = {
        apiVersion = "v1";
        kind = "Secret";
        metadata = {
          inherit namespace;

          name = "${admin-account-name}-token";
          annotations."kubernetes.io/service-account.name" = admin-account-name;
        };
        type = "kubernetes.io/service-account-token";
      };
    };

    "${admin-account-name}-rbac" = let
      rbacForNamespace = forNamespace: {
          apiVersion = "rbac.authorization.k8s.io/v1";
          kind = "ClusterRoleBinding";

          metadata = {
            namespace = forNamespace;
            name = admin-account-name;
          };

          roleRef = {
            apiGroup = "rbac.authorization.k8s.io";
            kind = "ClusterRole";
            # TODO: give a read-only role to this user.
            name = "cluster-admin";
          };

          subjects = [
            {
              inherit namespace;

              kind = "ServiceAccount";
              name = admin-account-name;
            }
          ];
      };
    in {
      
        enable = true;
        target = "${admin-account-name}.rbac.serviceaccount.yaml";
        content = 
[
      (rbacForNamespace "default")
      (rbacForNamespace namespace)
    ];
    };  };
}
