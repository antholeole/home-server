{...}: {
  nix = {
    enable = true;
    nix.gc.automatic = true;
    settings.experimental-features = ["nix-command" "flakes"];
  };
}
