{pkgs,...}: {
  environment.systemPackages = with pkgs;[
    btm
  ];
}
