{ config, pkgs, ... }:

{
  imports =
    [
      ./fonts.nix
      ../sound-pulseaudio.nix
    ];

  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw

  programs = {
    dconf.enable = true;
    seahorse.enable = true;
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
      startx.enable = true ;
      lightdm.enable = false ;
      gdm = {
        enable = true ;
        wayland = false ;
      };
    };

    layout = "us";
    libinput.enable = true;
    xkbVariant = "";
  };

#  services.greetd = {
#    enable = true;
#    settings = {
#      default_session = {
#        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time";
#        user = "greeter";
#      };
#    };
#  };

  security = {
    pam = {
      services.gdm.enableGnomeKeyring = true;
    };
    polkit = {
      enable = true;
    };
  };

  services = {
    gvfs.enable = true;                 # Mount, trash, and other functionalities
    gnome.gnome-keyring.enable = true;
  };
}

