{...}: {
  perSystem = {pkgs, ...}: {
    packages.server = (import ../server) pkgs;
  };
}
