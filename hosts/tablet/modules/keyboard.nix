{pkgs-unstable,...}: {
  services.libinput.enable = true;

  environment.systemPackages = with pkgs-unstable; [
    wvkbd
  ];
}
