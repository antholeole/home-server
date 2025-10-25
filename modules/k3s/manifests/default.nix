{...}: {
  imports = [
    ./external-dns.nix # does not work with cdk8s
    ./longhorn.nix # too hard to uninstall; maybe in another life.
    ./flux.nix # bootstrap the repo
  ];
}
