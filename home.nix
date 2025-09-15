{ config, pkgs, ... }:

let
  py = pkgs.python312.withPackages (ps: [
    ps.numpy
    ps.opencv4
    ps.pillow
    ps.requests
    ps.i3ipc
    ps.pip
  ]);
in
{
  home.username = "oscar";
  home.homeDirectory = "/home/oscar";
  home.stateVersion = "24.11";

  imports = [
    ./firefox.nix
    ./readwise.nix
    ./distractions.nix
  ];

  # Your dotfiles
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
    ".config/i3/alex.png".source = ./i3/alex.png;
    ".config/i3/alternating_layouts.py".source = ./i3/alternating_layouts.py;
    ".config/i3/wall.png".source = ./i3/wall.png;
    ".config/polybar/config.ini".source = ./polybar/config.ini;
    ".config/polybar/deadcon.sh".source = ./polybar/deadcon.sh;
    ".config/polybar/launch.sh".source = ./polybar/launch.sh;
    ".config/polybar/daily_wordcount.sh".source = ./polybar/daily_wordcount.sh;
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

  # No PYTHONPATH override necessary; Nix wires it up.
  # (Leaving this empty avoids version mismatches)
  home.sessionVariables = { };

  # Packages
  home.packages = with pkgs; [
    py
    home-manager
    alacritty
    i3
    i3lock
    zip
    dunst
    polybarFull
    ranger
    rofi
    nerd-fonts.roboto-mono
    nerd-fonts.symbols-only
    emacs30
    git
    ripgrep
    fd
    kdePackages.okular
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
    fortune
    prismlauncher
    jq
    discord
    rustc
    cargo
    at
    rpi-imager
    sshfs
    android-tools
    gimp
    virtualbox
    ncspot
    inetutils
    cool-retro-term
    poppler-utils
    qpdf
    unzip
    xprintidle
  ];
}
