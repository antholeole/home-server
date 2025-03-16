{...}: {
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

  # TODO: this is a hack that works because we only use a single node.
  mkNodeport = {
    namespace,
    name,
    from,
    to,
    selectors,
  }: {
    enable = true;
    target = "${name}.yaml";
    content = {
      kind = "Service";
      apiVersion = "v1";
      metadata = {
        inherit namespace name;
      };
      spec = {
        type = "NodePort";
        selector = selectors;

        ports = [
          {
            port = from;
            nodePort = to;
            protocol = "TCP";
          }
        ];
      };
    };
  };

  longhorn.storageClass.main = "longhorn-main";
}
