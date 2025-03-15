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
}
