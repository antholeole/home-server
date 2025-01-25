{...}: {
  nix = {
    enable = true;
    gc.automatic = true;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" "manager"];
    };
  };
}
