{
  pkgs,
  inputs,
  ags,
  ...
}: {
  home.packages = with pkgs; [
    watchexec # for dev, delete me

    inter-nerdfont

    # need
    inputs.ags.packages.${system}.agsFull # use an overlay. also, get rid of after dev
    # gtksourceview
    webkitgtk_4_1
    # accountsservice
  ];
}
