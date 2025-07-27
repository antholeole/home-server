{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    watchexec # for dev, delete me

    # need
    ags
    # gtksourceview
    webkitgtk_4_1
    # accountsservice
  ];
}
