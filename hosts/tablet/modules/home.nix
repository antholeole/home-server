{...}: {
  home-manager.users.manager = {pkgs, ...}: {
    home.stateVersion = "25.05";

    imports = [
      ./home/hypr.nix
    ];
  };
}
