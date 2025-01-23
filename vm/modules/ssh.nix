{
  inputs,
  lib,
  ssot,
  pkgs,
  ...
}: {
  # enable SSH in boot process.
  systemd.services.sshd.wantedBy = lib.mkForce ["multi-user.target"];
  users = {
    mutableUsers = false;
    users = {
      # nixos anywhere needs root ssh access...
      root.openssh.authorizedKeys.keys = ssot.public-keys;

      manager = {
        isNormalUser = true;
        description = "the user used to manage this server. Typically, only switches nixos generations.";
        extraGroups = ["wheel"];

        # TODO: don't get this by import
        openssh.authorizedKeys.keys = ssot.public-keys;

        packages = with pkgs; [
          kakoune
        ];
      };
    };
  };
}
