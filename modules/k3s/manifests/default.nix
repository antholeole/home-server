{...}: {
  imports = [
    ./external-dns.nix # does not work with cdk8s
    ./longhorn.nix # too many services depend on longhorn.
    ./flux.nix # bootstrap the repo
  ];
}
