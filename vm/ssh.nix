{inputs, ...}: {
  users.users = {
    # disable root ssh access
    root.hashedPassword = "!";

    manager = {
      isNormalUser = true;
      description = "the user used to manage this server. Typically, only switches nixos generations.";
      extraGroups = ["wheel"];

      # TODO: don't get this by import
      openssh.authorizedKeys.keys = import "${inputs.self}/ssot/keys.nix".public-keys;
    };
  };
}
