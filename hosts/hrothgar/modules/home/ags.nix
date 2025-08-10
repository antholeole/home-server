{inputs, pkgs-unstable,...}: {
  nixpkgs.overlays = [
    (old: new: let
      hrothgar-widgets = import ./home/agsv4 inputs pkgs-unstable;
    in {
      inherit hrothgar-widgets;
    })
  ];
}
