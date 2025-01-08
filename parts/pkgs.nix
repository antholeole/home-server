{...}: {
  perSystem = {pkgs, ...}: {
    packages.server = (import ../server) pkgs;
    packages.client-app = (import ../client) pkgs;
  };
}
