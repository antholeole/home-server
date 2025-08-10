#  import this to get everything required to make a system
{
  flake-config,
  inputs,
  ...
}: {
  imports = with flake-config.flake.modules.nixos; [
    inputs.nixos-hardware.nixosModules.microsoft-surface-go
    inputs.home-manager.nixosModules.home-manager

    ./hardware-config.nix

    ./modules/keyboard.nix
    ./modules/sddm.nix
    ./modules/screenmgmt.nix
    ./modules/hypr.nix
    ./modules/home.nix
    ./modules/upower.nix
    ./modules/qt.nix

    boilerplate
    disk-efi
  ];

  services.tlp.enable = true; # insane power savings
  services.libinput.enable = true; # so we can use the stylus

  networking.hostName = "hrothgar";
  diskName = "/dev/sdb";
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAFHW56n1jPSySEO3GtALBDEcE8tu4prtAzfRgPJSHn8";

}
