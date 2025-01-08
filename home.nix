{ config, pkgs, ... }:

let
  python_env = pkgs.python3.withPackages (ps: with ps; [
    pip
    numpy
    requests
    i3ipc
  ]);
in

{
  home.username = "oscar";
  home.homeDirectory = "/home/oscar";
  home.stateVersion = "24.11";

  imports = [
    ./firefox.nix
    ./readwise.nix
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Configuration files and locations
  home.file = {
    ".config/alacritty/alacritty.toml".source = ./alacritty/alacritty.toml;
    ".config/alacritty/alacritty.yml".source = ./alacritty/alacritty.yml;
    ".bashrc".source = ./.bashrc;
    ".inputrc".source = ./.inputrc;
    ".config/dunst/dunstrc".source = ./dunst/dunstrc;
    ".config/i3/config".source = ./i3/config;
    ".config/i3/lockscreen.sh".source = ./i3/lockscreen.sh;
    ".config/i3/monitors.sh".source = ./i3/monitors.sh;
    ".config/i3/burpcheck.sh".source = ./i3/burpcheck.sh;
    ".config/i3/redacted.png".source = ./i3/redacted.png;
    ".config/i3/alternating_layouts.py".source = ./i3/alternating_layouts.py;
    ".config/i3/wall.png".source = ./i3/wall.png;
    ".config/polybar/config.ini".source = ./polybar/config.ini;
    ".config/polybar/deadcon.sh".source = ./polybar/deadcon.sh;
    ".config/polybar/launch.sh".source = ./polybar/launch.sh;
    ".config/polybar/promodoro_duration.sh".source = ./polybar/promodoro_duration.sh;
    ".config/polybar/spotify_status.py".source = ./polybar/spotify_status.py;
    ".config/polybar/tun_script.sh".source = ./polybar/tun_script.sh;
    ".config/polybar/countdown.sh".source = ./polybar/countdown.sh;
    ".config/ranger/commands_full.py".source = ./ranger/commands_full.py;
    ".config/ranger/commands.py".source = ./ranger/commands.py;
    ".config/ranger/rc.conf".source = ./ranger/rc.conf;
    ".config/ranger/rifle.conf".source = ./ranger/rifle.conf;
    ".config/ranger/scope.sh".source = ./ranger/scope.sh;
    ".config/rofi/config.rasi".source = ./rofi/config.rasi;
    ".config/rofi/default.rasi".source = ./rofi/default.rasi;
  };

  home.sessionVariables = {
    PYTHONPATH = "${python_env}/lib/python3.10/site-packages";
    OPENAI_API_KEY = "$(cat ~/.openai_api_key)";
  };

  # Specify additional packages to be installed
  home.packages = with pkgs; [
    python_env
    home-manager
    alacritty
    i3
    dunst
    polybarFull
    ranger
    rofi
    nerdfonts
    emacs29
    git
    ripgrep
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
    pavucontrol
    nextcloud-client
    emacs-all-the-icons-fonts
    fzf
    termdown
    arandr
    networkmanager
    libreoffice
    noto-fonts
    chromium
    xclip
    feh
    imagemagick
    scrot
    signal-desktop
    networkmanagerapplet
    zotero
    autorandr
    remmina
    brightnessctl
    rubber
    gnumake
    texlive.combined.scheme-full
    mpv
    killall
    burpsuite
    fortune
    prismlauncher
    jq
    nmap
    discord
    gpt4all
  ];
}
