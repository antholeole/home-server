{
  ssot,
  ...
}: {
  mkNamespace = namespace: config: {
    enable = config.services.k3s.role == "server";

    content = {
      apiVersion = "v1";
      kind = "Namespace";
      metadata = {
        name = namespace;
        labels.name = namespace;
      };
    };
  };
}
