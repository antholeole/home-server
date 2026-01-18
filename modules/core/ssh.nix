{
  lib,
  ssot,
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
      root.openssh.authorizedKeys.keys = ssot.public-keys;

      manager = {
        isNormalUser = true;
        description = "main user";
        extraGroups = ["wheel"];

        hashedPassword = lib.mkDefault "$y$j9T$SVk9MmOKoGETAjhzDCidA/$WYjszgHqPu9T2sSBEkR4gJyoL9XniYdmaruJ1zeoIx8";
        openssh.authorizedKeys.keys = ssot.public-keys;
      };
    };
  };
}
