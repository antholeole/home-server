{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    watchexec # for dev, delete me

    # need
    # gtksourceview
    # webkitgtk_4_1
    # accountsservice
  ];
}
