{...}: {
  imports = [
    ./ingress-nginx.nix
    ./cert-manager.nix
    ./sealed-secrets.nix
    ./external-dns.nix
    ./longhorn.nix
    ./flux.nix
  ];
}
