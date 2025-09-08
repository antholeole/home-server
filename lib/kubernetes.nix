{
  ssot,
  ...
}: {
  mkNamespace = namespace: config: {
    enable = config.networking.hostName == ssot.k3sServer;

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
