{...}: {
  home-manager = {
    extraSpecialArgs = {};

    users.manager = {pkgs, ...}: {
      home.stateVersion = "25.05";

      imports = [
        ./home/hypr
        ./home/ags

        ./firefox.nix
      ];

      home.packages = with pkgs; [
        waypipe
      ];
    };
  };
}
