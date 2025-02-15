{ config, pkgs, lib, ... }:

let
  # Define a Python environment with necessary packages
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [ requests ]);
in
{
  # Define the systemd user service for distraction check
  systemd.user.services.distraction_check = {
    Unit = {
      Description = "Check if distractions are enabled";
    };
    Service = {
      ExecStart = "/home/oscar/Mimisbrunnr/.secrets/distraction_check.sh";
      Restart = "always";
      RestartSec = 60;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Define the systemd user timer to run the service every minute
  systemd.user.timers.distraction_check = {
    Unit = {
      Description = "Run distraction_check.sh every minute";
    };
    Timer = {
      OnCalendar = "*:0/1";
      Persistent = true;
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
