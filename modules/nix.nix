{...}: {
  nix = {
    enable = true;
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" "manager"];
    };
  };
}
