{ config, pkgs, ... }:

{
  imports = [ <home-manager/nixos> ];

  networking.hostName = "mimisbrunnr";
  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_TIME = "nl_NL.UTF-8";

  # Leesbare TTY
  console = {
    keyMap = "us";
    font = "ter-132n";
    packages = with pkgs; [ terminus_font ];
  };

  # Simpel netwerk
  networking.networkmanager.enable = true;

  # User
  users.users.oscar = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.bashInteractive;
  };
  security.sudo.enable = true;

  # Geen X/Wayland
  services.xserver.enable = false;

  # Boot -> autologin tty1 -> tmux -> emacsclient -nw (daemon via HM)
  services.greetd = {
    enable = true;
    settings.default_session = {
      user = "oscar";
      command = ''${pkgs.bash}/bin/bash -lc '${pkgs.tmux}/bin/tmux new -A -s main \
        "${pkgs.emacs29-nox}/bin/emacsclient -nw -a ${pkgs.emacs29-nox}/bin/emacs"'''';
    };
  };

  # Minimale tools
  environment.systemPackages = with pkgs; [
    git tmux curl wget openssh cadaver
  ];

  # Home Manager: laadt de user-config uit deze repo
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.oscar = import /home/oscar/.config/home-manager/home.nix;
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.05";
}
