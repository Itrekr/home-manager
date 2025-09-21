{ config, pkgs, ... }:

{
  # Home-Manager as a NixOS module (24.05 via root channel; setup.sh adds it)
  imports = [ <home-manager/nixos> ];

  # ---- Minimal base OS ----
  networking.hostName = "mimisbrunnr";
  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_TIME = "nl_NL.UTF-8";

  # TTY readability
  console = {
    keyMap = "us";
    font = "ter-132n";
    packages = with pkgs; [ terminus_font ];
  };

  # Networking (no GUI)
  networking.networkmanager.enable = true;

  # User
  users.users.oscar = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.bashInteractive;
    home = "/home/oscar";
  };

  security.sudo.enable = true;

  # No X/Wayland
  services.xserver.enable = false;

  # Autologin straight to Emacs in tmux on tty1
  services.greetd = {
    enable = true;
    settings.default_session = {
      user = "oscar";
      command = ''${pkgs.bash}/bin/bash -lc '${pkgs.tmux}/bin/tmux new -A -s main \
        "${pkgs.emacs29-nox}/bin/emacsclient -nw -a ${pkgs.emacs29-nox}/bin/emacs"'''';
    };
  };

  # Minimal handy tools
  environment.systemPackages = with pkgs; [
    git tmux curl wget openssh cadaver
  ];

  # Home-Manager user config (loads the home.nix from your repo)
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.oscar = import /home/oscar/.config/home-manager/home.nix;
  };

  nixpkgs.config.allowUnfree = true;

  # Target this stable release
  system.stateVersion = "24.05";
}
