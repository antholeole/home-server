{
  lib,
  ssot,
  pkgs,
  ...
}: {
  services.k3s.manifests = let
    namespace = "kubernetes-dashboard";
    admin-account-name = "dashboard-admin";
    service-name = "kubernetes-dashboard-service";
    service-port = 8000;
  in {
    dashboard-namespace = lib.homeServer.kubernetes.mkNamespace namespace;

    dashboard = {
      enable = true;
      content = let
        yamls = lib.kubelib.fromHelm {
          inherit namespace;

          name = "kubernetes-dashboard";
          chart = pkgs.helm-charts.kubernetes-dashboard.kubernetes-dashboard;

          values = {
            # fix for https://github.com/Kong/kong/issues/13730
            # and https://github.com/Kong/kong/issues/13730
            kong.image.tag = "3.9";
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
      content = [
        (rbacForNamespace "default")
        (rbacForNamespace namespace)
      ];
    };

    dashboard-service = {
      enable = true;

      content = {
        kind = "Service";
        apiVersion = "v1";
        metadata = {
          inherit namespace;
          name = service-name;
        };
        spec = {
          selector = {
            "app.kubernetes.io/instance" = "kubernetes-dashboard";
            "app.kubernetes.io/name" = "kubernetes-dashboard-web";
            "app.kubernetes.io/part-of" = "kubernetes-dashboard";
          };
          ports = [
            {
              port = 8000;
              targetPort = service-port;
              protocol = "TCP";
            }
          ];
        };
      };
    };

    dashboard-ingress = {
      enable = true;
      content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          inherit namespace;
          name = "dashboard-ingress-route";
          annotations."cert-manager.io/cluster-issuer" = "cf-issuer";
        };
        spec = {
          ingressClassName = "nginx";
          tls = [
            {
              secretName = "dashboard-tls";
              hosts = [
                "dashboard.${ssot.cloudflare.domain}"
              ];
            }
          ];
          rules = [
            {
              host = "dashboard.${ssot.cloudflare.domain}";
              http.paths = [
                {
                  path = "/";
                  pathType = "Prefix";
                  backend.service = {
                    name = service-name;
                    port.number = service-port;
                  };
                }
              ];
            }
          ];
        };
      };
    };
  };
}
