{ config, pkgs, ... }:

{
  # Import Home-Manager module + your machine's hardware config
  imports = [
    <home-manager/nixos>
    ./hardware-configuration.nix   # NOTE: resolves relative to /etc/nixos after symlink
  ];

  # ---- Base OS ----
  networking.hostName = "mimisbrunnr";
  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = { LC_TIME = "nl_NL.UTF-8"; };

  # Console (TTY) readability
  console = {
    keyMap = "us";
    font = "ter-132n";
    packages = with pkgs; [ terminus_font ];
  };

  # Networking
  networking.networkmanager.enable = true;

  # Users
  users.users.oscar = {
    isNormalUser = true;
    home = "/home/oscar";
    shell = pkgs.bashInteractive;
    extraGroups = [ "wheel" "networkmanager" ];
  };
  security.sudo.enable = true;

  # No X/Wayland
  services.xserver.enable = false;

  # Boot loader (UEFI). If you’re on legacy BIOS, use the GRUB block below instead.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # --- If you use legacy BIOS instead of UEFI, comment the two lines above
  # --- and uncomment the GRUB lines below:
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/sda";   # set your disk device here (not a partition)
  # boot.loader.grub.useOSProber = false;

  # Autologin -> tmux -> emacsclient -nw
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = "oscar";
        command = "${pkgs.tmux}/bin/tmux new -A -s main \"${pkgs.emacs29-nox}/bin/emacsclient -nw -a ${pkgs.emacs29-nox}/bin/emacs\"";
      };
    };
  };

  # Handy tools
  environment.systemPackages = with pkgs; [
    git tmux curl wget openssh cadaver
  ];

  # Home-Manager user config (loads your home.nix from this repo)
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.oscar = import /home/oscar/.config/home-manager/home.nix;
  };

  nixpkgs.config.allowUnfree = true;

  # Target NixOS 24.05
  system.stateVersion = "24.05";
}
