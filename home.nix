{ config, pkgs, lib, ... }:

let
  emacsPkg = pkgs.emacs29-nox;  # TTY build; Doom core ( ~/.config/emacs ) + jouw config ( ~/.config/doom )
in
{
  home.username = "oscar";
  home.homeDirectory = "/home/oscar";
  programs.home-manager.enable = true;

  # Pakketten: lean
  home.packages = with pkgs; [
    emacsPkg
    git ripgrep fd tree gnupg
    aspell aspellDicts.en aspellDicts.nl
    nextcloud-client rclone
    openssh
    # GUI-fonts voor later; TTY gebruikt console-font
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" "Iosevka" ]; })
    poppins
  ];

  # Emacs daemon (laadt jouw Doom setup automatisch)
  services.emacs = {
    enable = true;
    package = emacsPkg;
    startWithUserSession = "default";
  };

  # Shell basics
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
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
    };
  };

  programs.tmux.enable = true;

  # SSH client: keys naar agent, GitHub host entry via bootstrap
  home.file.".ssh/config".text = ''
    Host github.com
      AddKeysToAgent yes
      IdentityFile ~/.ssh/id_ed25519
      IdentitiesOnly yes
  '';

  # Nextcloud/Mimisbrunnr: env-bestand (je vult ’m zelf)
  home.file.".config/nextcloud-sync.env".text = ''
    # Vereist:
    NEXTCLOUD_URL="https://cloud.example.org/remote.php/dav/files/YOURUSER"
    NEXTCLOUD_USER="YOURUSER"
    NEXTCLOUD_PASS="YOUR_APP_PASSWORD"  # gebruik een app password
    LOCAL_DIR="$HOME/Mimisbrunnr"
  '';

  # Systemd user-service + timer voor sync
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

  # One-shot Doom bootstrap (privé repo vriendelijk)
  # Draait alleen als ~/.config/doom nog niet bestaat; markeert met stampfile.
  home.file.".config/home-manager/scripts/doom_bootstrap.sh" = {
    source = ./scripts/doom_bootstrap.sh;
    executable = true;
  };
  home.file.".config/home-manager/scripts/nextcloud_mimi_sync.sh" = {
    source = ./scripts/nextcloud_mimi_sync.sh;
    executable = true;
  };
  home.file.".config/doom.private.env".text = ''
    # Optioneel: fallback token voor HTTPS clone van je private repo
    # DOOM_GIT_TOKEN="ghp_..."
    # Of custom URLs:
    # DOOM_GIT_URL_SSH="git@github.com:Itrekr/doom.git"
    # DOOM_GIT_URL_HTTPS="https://github.com/Itrekr/doom.git"
  '';

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
