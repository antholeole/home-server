{
  inputs,
  pkgs-unstable,
  ...
}: {
  home-manager = {
    extraSpecialArgs = {
      inherit inputs pkgs-unstable;
    };

    users.manager = {
      pkgs,
      pkgs-unstable,
      ...
    }: {
      home.stateVersion = "25.05";

      nixpkgs.overlays = [
        inputs.nixzx.overlays.default
      ];


      imports = [
        ./home/hypr
        ./home/agsv4
        ./firefox.nix
      ];
    };
  };
}
