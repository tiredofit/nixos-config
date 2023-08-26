{ config, pkgs, ... }:

{
  imports =
    [
      ./fonts.nix
    ];

  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw
  programs = {
    dconf.enable = true;
    seahorse.enable = true;
  };

  host = {
    hardware.sound.server = mkForce "pipewire";
  };

  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      session = [
        {
          name = "home-manager";
          start = ''
            ${pkgs.runtimeShell} $HOME/.hm-xsession &
            waitPID=$!
          '';
        }
      ];
    };

    displayManager = {
      startx.enable = false ;
      lightdm.enable = false ;
      gdm = {
        enable = false ;
        wayland = false ;
      };
    };

    layout = "us";
    libinput.enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time";
        user = "greeter";
      };
    };
  };

  security = {
    pam = {
      services = {
       gdm.enableGnomeKeyring = true;
       swaylock.text = ''
         # PAM configuration file for the swaylock screen locker. By default, it includes
         # the 'login' configuration file (see /etc/pam.d/login)
         auth include login
       '';
      };
    };
    polkit = {
      enable = true;
    };
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  services = {
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true;                 # Mount, trash, and other functionalities
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };
  };
}

