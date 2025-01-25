#  import this to get everything required to make a system
{config, ...}: {
  imports = with config.flake.modules.nixos; [
    ./disk.nix
    ./tablet-hardware-config.nix

    boilerplate
  ];
}
