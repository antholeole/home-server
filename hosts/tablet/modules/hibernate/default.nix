{pkgs, ...}: {
  systemd.services.hibernate-check = {
    description = "Check if the system should hibernate";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = let
        hibernate-ts = pkgs.writeZxApplication {
          name = "hibernate-ts";
          runtimeInputs = [
            pkgs.bash
            pkgs.hyprland
            pkgs.systemd
          ];

          src = ./sleep.ts;
        };
      in "${hibernate-ts}/bin/hibernate-ts";
    };
  };

  systemd.timers.hibernate-check = {
    description = "Run hibernate check every 5 minutes";
    timerConfig = {
      OnCalendar = "*:0/5";
      Persistent = true;
    };
    wantedBy = ["timers.target"];
    partOf = ["hibernate-check.service"];
  };
}
