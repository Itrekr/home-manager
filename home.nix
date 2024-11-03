{ config, pkgs, ... }:

{
  home.username = "oscar";
  home.homeDirectory = "/home/oscar";
  home.stateVersion = "24.05";
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Configuration files and locations
  home.file = {
    # Alacritty configuration
    ".config/alacritty/alacritty.toml".source = ./alacritty/alacritty.toml;
    ".config/alacritty/alacritty.yml".source = ./alacritty/alacritty.yml;

    # Bash configurations
    ".bashrc".source = ./.bashrc;
    ".inputrc".source = ./.inputrc;

    # Dunst configuration
    ".config/dunst/dunstrc".source = ./dunst/dunstrc;

    # i3 configuration
    ".config/i3/config".source = ./i3/config;
    ".config/i3/lockscreen.sh".source = ./i3/lockscreen.sh;
    ".config/i3/monitors.sh".source = ./i3/monitors.sh;
    ".config/i3/burpcheck.sh".source = ./i3/burpcheck.sh;
    ".config/i3/chains.png".source = ./i3/chains.png;

    # Polybar configuration
    ".config/polybar/config.ini".source = ./polybar/config.ini;
    ".config/polybar/deadcon.sh".source = ./polybar/deadcon.sh;
    ".config/polybar/launch.sh".source = ./polybar/launch.sh;
    ".config/polybar/promodoro_duration.sh".source = ./polybar/promodoro_duration.sh;
    ".config/polybar/spotify_status.py".source = ./polybar/spotify_status.py;
    ".config/polybar/tun_script.sh".source = ./polybar/tun_script.sh;

    # Ranger configuration
    ".config/ranger/commands_full.py".source = ./ranger/commands_full.py;
    ".config/ranger/commands.py".source = ./ranger/commands.py;
    ".config/ranger/rc.conf".source = ./ranger/rc.conf;
    ".config/ranger/rifle.conf".source = ./ranger/rifle.conf;
    ".config/ranger/scope.sh".source = ./ranger/scope.sh;

    # Rofi configuration
    ".config/rofi/config.rasi".source = ./rofi/config.rasi;
    ".config/rofi/default.rasi".source = ./rofi/default.rasi;
  };

  # Specify additional packages to be installed
  home.packages = with pkgs; [
    alacritty
    i3
    dunst
    (polybar.override {i3Support = true;})
    ranger
    rofi
    nerdfonts
    emacs29
    git
    ripgrep
    coreutils
    fd
    okular
    clang
    gnupg
    spotify
    hunspell
    hunspellDicts.nl_NL
    hunspellDicts.en_US
    flameshot
    direnv
    nix-direnv
    pulseaudio
    nextcloud-client
    emacs-all-the-icons-fonts
    fzf
    termdown
    arandr
    networkmanager
    libreoffice
    gnome-keyring
  ];
}
