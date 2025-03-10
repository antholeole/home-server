{...}: {
  # the manifests required to setup a basic kubernetes admin role, primarily
  # to access the kubernetes dashboard, but can be used for many other things
  # as well.
  services.k3s.manifests = let
    admin-account-name = "dashboard-admin";
  in {
    "${admin-account-name}" = {
      enable = true;
      target = "${admin-account-name}.serviceaccount.yaml";
      content = {
        apiVersion = "v1";
        kind = "ServiceAccount";
        metadata = {
          name = admin-account-name;
          namespace = "default";
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
          name = "${admin-account-name}-token";
          namespace = "default";
          annotations."kubernetes.io/service-account.name" = admin-account-name;
        };
        type = "kubernetes.io/service-account-token";
      };
    };

    "${admin-account-name}-rbac" = {
      enable = true;
      target = "${admin-account-name}.rbac.serviceaccount.yaml";
      content = {
        apiVersion = "rbac.authorization.k8s.io/v1";
        kind = "ClusterRoleBinding";

        metadata.name = admin-account-name;
        roleRef = {
          apiGroup = "rbac.authorization.k8s.io";
          kind = "ClusterRole";
          name = "cluster-admin";
        };

        subjects = [
          {
            kind = "ServiceAccount";
            name = admin-account-name;
            namespace = "default";
          }
        ];
      };
    };
  };
}
