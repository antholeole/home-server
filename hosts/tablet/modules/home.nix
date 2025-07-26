{inputs,...}: {
  home-manager.users.manager = {pkgs, ...}: {
    home.stateVersion = "25.05";

    extraSpecialInputs = {
      inherit inputs;
    };

    imports = [
      ./home/hypr
      ./home/ags

      ./firefox.nix
    ];

    home.packages = with pkgs; [
      waypipe
    ];
  };
}
