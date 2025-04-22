{ config, pkgs, lib, ... }:

{
  ### Assumes you're managing user services via Home Manager

  systemd.user.services.distraction_check = {
    Unit = {
      Description = "Send PC online & wordcount data to Home Assistant";
      After = [ "network.target" ];
    };

    Service = {
      Type = "oneshot";

      # Make sure the script is executable and at this path
      ExecStart = "${config.home.homeDirectory}/Mimisbrunnr/.secrets/distraction_check.sh";

      # Optionally load environment secrets from a file
      # You can put TOKEN in ~/.config/hass/env
      #
      # EnvironmentFile = "%h/.config/hass/env";

      # Journal log integration
      StandardOutput = "journal";
      StandardError = "journal";
    };

    Install = {
      WantedBy = [ "default.target" ]; # Required if you want to manually start
    };
  };

  systemd.user.timers.distraction_check = {
    Unit = {
      Description = "Run distraction_check.sh every minute";
    };

    Timer = {
      OnCalendar = "*:0/1";       # Every minute
      Persistent = true;
      Unit = "distraction_check.service";
    };

    Install = {
      WantedBy = [ "timers.target" ];  # This ensures it runs automatically
    };
  };
}
