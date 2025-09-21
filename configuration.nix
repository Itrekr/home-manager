{ config, pkgs, ... }:

{
  # Gebruik Home-Manager als NixOS-module
  imports = [ <home-manager/nixos> ];

  # --- Basis ---
  networking.hostName = "mimisbrunnr";
  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = { LC_TIME = "nl_NL.UTF-8"; };

  # Leesbare TTY
  console = {
    keyMap = "us";
    font = "ter-132n";
    packages = with pkgs; [ terminus_font ];
  };

  # Netwerk
  networking.networkmanager.enable = true;

  # User
  users.users.oscar = {
    isNormalUser = true;
    home = "/home/oscar";
    shell = pkgs.bashInteractive;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  security.sudo.enable = true;

  # Geen X/Wayland
  services.xserver.enable = false;

  # Autologin -> tmux -> emacsclient -nw
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = "oscar";
        # Let op de escaping van quotes binnen de string
        command = "${pkgs.tmux}/bin/tmux new -A -s main \"${pkgs.emacs29-nox}/bin/emacsclient -nw -a ${pkgs.emacs29-nox}/bin/emacs\"";
      };
    };
  };

  # Handige tools
  environment.systemPackages = with pkgs; [
    git tmux curl wget openssh cadaver
  ];

  # Home-Manager user config uit je repo
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.oscar = import /home/oscar/.config/home-manager/home.nix;
  };

  nixpkgs.config.allowUnfree = true;

  # Target NixOS 24.05
  system.stateVersion = "24.05";
}
