{inputs,...}: {
  home-manager = {
    extraSpecialArgs = {
      
        inherit inputs;
    };

    users.manager = {pkgs, ...}: {
      home.stateVersion = "25.05";

      imports = [
        ./home/hypr
        ./home/agsv4

        ./firefox.nix
      ];

      home.packages = with pkgs; [
        waypipe
      ];
    };
  };
}
