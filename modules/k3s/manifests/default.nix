{...}: {
  imports = [
    ./ingress-nginx.nix
    ./cert-manager.nix
    ./sealed-secrets.nix
    ./cnpg.nix
    ./external-dns.nix
    ./flux.nix
    ./authentik.nix
  ];
}
