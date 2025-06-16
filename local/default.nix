pkgs: {
  devShell = pkgs.lib.mkShell {
    pkgs = with pkgs; [
      nerdctl
      k3d
    ];
    
  };
}
