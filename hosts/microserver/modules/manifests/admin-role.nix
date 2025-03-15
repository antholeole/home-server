{...}: {
  # the manifests required to setup a basic kubernetes admin role, primarily
  # to access the kubernetes dashboard, but can be used for many other things
  # as well.
  services.k3s.manifests = let
  in {
  };
}
