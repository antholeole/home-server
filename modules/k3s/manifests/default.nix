{...}: {
  imports = [
    ./ingress-nginx.nix
    ./cert-manager.nix
    ./sealed-secrets.nix
    ./reflector.nix
    ./cnpg.nix
    ./external-dns.nix
    ./longhorn.nix
    ./flux.nix
    ./authentik.nix
  ];
}
