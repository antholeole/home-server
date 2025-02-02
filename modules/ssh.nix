{
  inputs,
  lib,
  ssot,
  pkgs,
  ...
}: {
  # enable SSH in boot process.
  systemd.services.sshd.wantedBy = lib.mkForce ["multi-user.target"];
  services.openssh.enable = true;

  # passwordless sudo
  security.sudo.wheelNeedsPassword = false;
  users = {
    mutableUsers = false;
    users = {
      # nixos anywhere needs root ssh access...
      root.openssh.authorizedKeys.keys = ssot.public-keys;

      manager = {
        isNormalUser = true;
        description = "the user used to manage this server. Typically, only switches nixos generations.";
        extraGroups = ["wheel"];

        # python3 -c 'import crypt; print(crypt.crypt("1111", "$y$j9T$"))'
        hashedPassword = "$y$j9T$$wfS3vxRHU4C86kX/3ml/KDvTTi4Y1xC/c/WL.pqLJ1/";

        # TODO: don't get this by import
        openssh.authorizedKeys.keys = ssot.public-keys;

        packages = with pkgs; [
          kakoune
        ];
      };
    };
  };
}
