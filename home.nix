{ config, pkgs, ... }:

let
  emacsPkg = pkgs.emacs29-nox;  # TTY build on 24.05
in
{
  home.username = "oscar";
  home.homeDirectory = "/home/oscar";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    emacsPkg
    git ripgrep fd tree gnupg
    aspell aspellDicts.en aspellDicts.nl
    nextcloud-client rclone
    openssh
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" "Iosevka" ]; })
  ];

  # Emacs daemon as a user unit (robust on 24.05)
  systemd.user.services.emacs = {
    Unit = { Description = "Emacs Daemon"; };
    Service = {
      Type = "simple";
      ExecStart = "${emacsPkg}/bin/emacs --daemon";
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install = { WantedBy = [ "default.target" ]; };
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      e = "emacsclient -nw -a emacs";
      sync-mimi = "%h/.config/home-manager/scripts/nextcloud_mimi_sync.sh";
    };
  };

  programs.git = {
    enable = true;
    userName = "Oscar Scheepers";
    userEmail = "oscar@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
    };
  };

  programs.tmux.enable = true;

  home.file.".ssh/config".text = ''
    Host github.com
      AddKeysToAgent yes
      IdentityFile ~/.ssh/id_ed25519
      IdentitiesOnly yes
  '';

  home.file.".config/nextcloud-sync.env".text = ''
    NEXTCLOUD_URL="https://cloud.example.org/remote.php/dav/files/YOURUSER"
    NEXTCLOUD_USER="YOURUSER"
    NEXTCLOUD_PASS="YOUR_APP_PASSWORD"
    LOCAL_DIR="$HOME/Mimisbrunnr"
  '';

  home.file.".config/home-manager/scripts/doom_bootstrap.sh" = {
    source = ./scripts/doom_bootstrap.sh;
    executable = true;
  };
  home.file.".config/home-manager/scripts/nextcloud_mimi_sync.sh" = {
    source = ./scripts/nextcloud_mimi_sync.sh;
    executable = true;
  };

  home.file.".config/doom.private.env".text = ''
    # DOOM_GIT_TOKEN="ghp_..."
    # DOOM_GIT_URL_SSH="git@github.com:Itrekr/doom.git"
    # DOOM_GIT_URL_HTTPS="https://github.com/Itrekr/doom.git"
  '';

  systemd.user.services."nextcloud-mimi-sync" = {
    Unit = { Description = "Nextcloud sync for Mimisbrunnr"; };
    Service = {
      Type = "oneshot";
      ExecStart = "%h/.config/home-manager/scripts/nextcloud_mimi_sync.sh";
      Environment = "PATH=${pkgs.coreutils}/bin:${pkgs.findutils}/bin:${pkgs.nextcloud-client}/bin";
    };
    Install = { WantedBy = [ "default.target" ]; };
  };

  systemd.user.timers."nextcloud-mimi-sync" = {
    Unit = { Description = "Periodic Nextcloud sync"; };
    Timer = {
      OnBootSec = "1m";
      OnUnitActiveSec = "15m";
      Persistent = true;
    };
    Install = { WantedBy = [ "timers.target" ]; };
  };

  systemd.user.services."doom-bootstrap" = {
    Unit = {
      Description = "Bootstrap Doom (core + private config)";
      ConditionPathExists = "!%h/.local/share/doom_bootstrap.done";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "%h/.config/home-manager/scripts/doom_bootstrap.sh";
      Environment = "PATH=${pkgs.coreutils}/bin:${pkgs.findutils}/bin:${pkgs.git}/bin:${pkgs.openssh}/bin:${pkgs.curl}/bin";
    };
    Install = { WantedBy = [ "default.target" ]; };
  };

  home.stateVersion = "24.05";
}
