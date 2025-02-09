{...}: {
  # the manifests required to setup a basic kubernetes admin role, primarily
  # to access the kubernetes dashboard, but can be used for many other things
  # as well.
  services.k3s.manifests = let
    admin-account-name = "dashboard-admin";
    viewonly-role = "dashboard-viewonly";
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

    viewonly-clusterrole = {
      enable = true;
      target = "${viewonly-role}.role.yaml";
      content = {
        apiVersion = "rbac.authorization.k8s.io/v1";
        kind = "ClusterRole";
        metadata.name = viewonly-role;
        rules = [
          {
            apiGroups = [""];
            resources = [
              "configmaps"
              "endpoints"
              "persistentvolumeclaims"
              "pods"
              "replicationcontrollers"
              "replicationcontrollers/scale"
              "serviceaccounts"
              "services"
              "nodes"
              "persistentvolumeclaims"
              "persistentvolumes"
            ];
            verbs = ["get" "list" "watch"];
          }
          {
            apiGroups = [""];
            resources = [
              "bindings"
              "events"
              "limitranges"
              "namespaces/status"
              "pods/log"
              "pods/status"
              "replicationcontrollers/status"
              "resourcequotas"
              "resourcequotas/status"
            ];
            verbs = ["get" "list" "watch"];
          }
          {
            apiGroups = [""];
            resources = ["namespaces"];
            verbs = ["get" "list" "watch"];
          }
          {
            apiGroups = ["apps"];
            resources = [
              "daemonsets"
              "deployments"
              "deployments/scale"
              "replicasets"
              "replicasets/scale"
              "statefulsets"
            ];
            verbs = ["get" "list" "watch"];
          }
          {
            apiGroups = ["autoscaling"];
            resources = ["horizontalpodautoscalers"];
            verbs = ["get" "list" "watch"];
          }
          {
            apiGroups = ["batch"];
            resources = ["cronjobs" "jobs"];
            verbs = ["get" "list" "watch"];
          }
          {
            apiGroups = ["extensions"];
            resources = [
              "daemonsets"
              "deployments"
              "deployments/scale"
              "ingresses"
              "networkpolicies"
              "replicasets"
              "replicasets/scale"
              "replicationcontrollers/scale"
            ];
            verbs = ["get" "list" "watch"];
          }
          {
            apiGroups = ["policy"];
            resources = ["poddisruptionbudgets"];
            verbs = ["get" "list" "watch"];
          }
          {
            apiGroups = ["networking.k8s.io"];
            resources = ["networkpolicies"];
            verbs = ["get" "list" "watch"];
          }
          {
            apiGroups = ["storage.k8s.io"];
            resources = ["storageclasses" "volumeattachments"];
            verbs = ["get" "list" "watch"];
          }
          {
            apiGroups = ["rbac.authorization.k8s.io"];
            resources = [
              "clusterrolebindings"
              "clusterroles"
              "roles"
              "rolebindings"
            ];
            verbs = ["get" "list" "watch"];
          }
        ];
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
          name = viewonly-role;
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
