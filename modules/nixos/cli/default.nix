{ config, pkgs, ... }:

{
  imports = [
    ./bash.nix # Bash Script
    ./diceware.nix # Password Generator
    ./less.nix # pager
  ];

  environment.systemPackages = with pkgs; [

    binutils            # standard binutils
    coreutils           # gnu core utilities
    curl                # swiss army knife
    du-dust             # rust version of du
    git                 # git
    git-lfs             # git large file support
    htop                # process analysis
    iftop               # network i/o analysis
    inetutils           # internet tools
    iotop               # i/o analysis
    less                # pager
    links2              # console web browser
    lsof                # list open files
    mtr                 # traceroute
    ncdu                # disk usage gui
    nano                # editor
    nvd                 # Nix Diffs
    pciutils            # pci statistics
    power-profiles-daemon # dbus power profiles
    psmisc              # process analysis
    strace              # debug
    usbutils            # tools for working with usb devices
    wget                # file fetcher
  ];

  services.power-profiles-daemon.enable = true;
}
