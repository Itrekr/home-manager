{ config, pkgs, ... }:

let
  # 24.05 default: Emacs 29 (nox build for TTY). Doom core in ~/.config/emacs; your private config in ~/.config/doom
  emacsPkg = pkgs.emacs29-nox;
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
    # GUI fonts (harmless in TTY; nice if you ever add EXWM later)
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" "Iosevka" ]; })
    poppins
  ];

  # Emacs daemon; it will load Doom core (~/.config/emacs) + your config (~/.config/doom)
  services.emacs = {
    enable = true;
    package = emacsPkg;
    startWithUserSession = "default";
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      e = "emacsclient -nw -a emacs";
      sync-mimi = "~/.config/home-manager/scripts/nextcloud_mimi_sync.sh";
    };
  };

  programs.git = {
    enable = true;
    userName = "Oscar Scheepers";
    userEmail = "oscar@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      # Prefer SSH for GitHub (private repo-friendly)
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
    };
  };

  programs.tmux.enable = true;

  # Simple SSH client config; known_hosts handled by bootstrap script
  home.file.".ssh/config".text = ''
    Host github.com
      AddKeysToAgent yes
      IdentityFile ~/.ssh/id_ed25519
      IdentitiesOnly yes
  '';

  # Nextcloud/Mimisbrunnr env (you fill these)
  home.file.".config/nextcloud-sync.env".text = ''
    NEXTCLOUD_URL="https://cloud.example.org/remote.php/dav/files/YOURUSER"
    NEXTCLOUD_USER="YOURUSER"
    NEXTCLOUD_PASS="YOUR_APP_PASSWORD"
    LOCAL_DIR="$HOME/Mimisbrunnr"
  '';

  # Install the helper scripts
  home.file.".config/home-manager/scripts/doom_bootstrap.sh" = {
    source = ./scripts/doom_bootstrap.sh;
    executable = true;
  };
  home.file.".config/home-manager/scripts/nextcloud_mimi_sync.sh" = {
    source = ./scripts/nextcloud_mimi_sync.sh;
    executable = true;
  };

  # Optional private env with token / alt URLs for the private repo (not required if SSH works)
  home.file.".config/doom.private.env".text = ''
    # DOOM_GIT_TOKEN="ghp_..."
    # DOOM_GIT_URL_SSH="git@github.com:Itrekr/doom.git"
    # DOOM_GIT_URL_HTTPS="https://github.com/Itrekr/doom.git"
  '';

  # Nextcloud sync: user service + timer
  systemd.user.services."nextcloud-mimi-sync" = {
    Unit.Description = "Nextcloud sync for Mimisbrunnr";
    Service = {
      Type = "oneshot";
      ExecStart = "%h/.config/home-manager/scripts/nextcloud_mimi_sync.sh";
      Environment = "PATH=${pkgs.coreutils}/bin:${pkgs.findutils}/bin:${pkgs.nextcloud-client}/bin";
    };
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.timers."nextcloud-mimi-sync" = {
    Unit.Description = "Periodic Nextcloud sync";
    Timer = {
      OnBootSec = "1m";
      OnUnitActiveSec = "15m";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  # Doom bootstrap: runs once after login if not already stamped by its own script
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
    Install.WantedBy = [ "default.target" ];
  };

  home.stateVersion = "24.05";
}
