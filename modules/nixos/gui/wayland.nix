{ config, pkgs, ... }:


{
  imports =
    [
      ./fonts.nix
      ../locale.nix
      ../sound-pulseaudio.nix
      ./fonts.nix
    ];

  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw
  environment.systemPackages = with pkgs; [
    grim          # taking screenshots
    slurp         # selecting a region to screenshot

    wofi          # A rofi inspired launcher for wlroots compositors such as sway/hyprland
    mako          # the notification daemon, the same as dunst

    yad           # a fork of zenity, for creating dialogs

    # Media
    mpd           # for playing system sounds
    mpc-cli       # command-line mpd client
    ncmpcpp       # a mpd client with a UI
    networkmanagerapplet  # provide GUI app: nm-connection-editor
    xfce.thunar  # xfce4's file manager
  ]

  services.xserver = {
     enable = true;

    desktopManager = {
      xterm.enable = false;
    };

    displayManager = {
      startx.enable = false ;
      lightdm.enable = false ;
      gdm = {
        enable = true ;
        wayland = true ;
      };
    };
  };

  programs = {
    light.enable = true;     # monitor backlight control

    thunar.plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  }

  services = {
    gvfs.enable = true;    # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnail support for images
  }
}

