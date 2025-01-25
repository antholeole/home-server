{
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./tablet-hardware-config.nix
    inputs.nixos-hardware.nixosModules.microsoft-surface-go
  ];

  boot.loader = {
    systemd-boot.enable = true;
    grub.device = "nodev";
    efi.canTouchEfiVariables = true;
  };

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sdb";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };

            plainSwap = {
              size = "4G";
              content = {
                type = "swap";
                discardPolicy = "both";
                # allow hibernate from this device
                resumeDevice = true;
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
