{inputs, pkgs-unstable,...}: {
  nixpkgs.overlays = [
    (old: new: let
      tablet-widgets = import ./home/agsv4 inputs pkgs-unstable;
    in {
      inherit tablet-widgets;
    })
  ];
}
