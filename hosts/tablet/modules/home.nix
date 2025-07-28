{inputs,...}: {
  home-manager = {
    extraSpecialArgs = {
        inherit inputs;
    };

    users.manager = {pkgs, ...}: {
      home.stateVersion = "25.05";

      nixpkgs.overlays = [
        (old: new: let
            tablet-widgets = import ./home/agsv4 inputs pkgs;
          in {
            inherit tablet-widgets;
        })        
      ];

      imports = [
        ./home/hypr

        ./firefox.nix
      ];

      home.packages = with pkgs; [
        tablet-widgets
      ];
    };
  };
}
