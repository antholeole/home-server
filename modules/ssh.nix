{
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

        hashedPassword = "$y$j9T$SVk9MmOKoGETAjhzDCidA/$WYjszgHqPu9T2sSBEkR4gJyoL9XniYdmaruJ1zeoIx8";
        openssh.authorizedKeys.keys = ssot.public-keys;

        packages = with pkgs; [
          kakoune
        ];
      };
    };
  };
}
