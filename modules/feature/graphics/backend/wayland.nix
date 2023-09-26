{ config, lib, pkgs, specialArgs, ... }:
with lib;
let
  inherit (specialArgs) kioskUsername kioskURL;

  graphics = config.host.feature.graphics;
in {
  config = mkIf (graphics.enable && graphics.backend == "wayland") {
    environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw

    programs = mkIf (config.host.role != "kiosk") {
      dconf.enable = true;
      seahorse.enable = true;
      hyprland = {
       enable = true;
       package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      };
    };

    security = mkIf (config.host.role != "kiosk") {
      pam = {
        services.gdm.enableGnomeKeyring = true;
        services.swaylock.text = ''
         # PAM configuration file for the swaylock screen locker. By default, it includes
         # the 'login' configuration file (see /etc/pam.d/login)
         auth include login
       '';
      };
      polkit = {
        enable = true;
      };
    };

    services = lib.mkMerge [
    {
      cage = (lib.mkIf (config.host.role == "kiosk") {
        enable = true;
        user = "${kioskUsername}";
        program = "${pkgs.firefox}/bin/firefox -kiosk -private-window ${kioskURL}";
      });

      gvfs = (lib.mkIf (config.host.role != "kiosk") {
        enable = true;
      });

      gnome.gnome-keyring = (lib.mkIf (config.host.role != "kiosk") {
        enable = true;
      });

      greetd = (lib.mkIf (config.host.role != "kiosk") {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time";
            user = "greeter";
          };
        };
      });

      xserver = lib.mkMerge [
        (lib.mkIf (config.host.role != "kiosk") {
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
            startx.enable = true;
            lightdm.enable = false;
            gdm = {
              enable = false ;
              wayland = true ;
            };
          };
          layout = "us";
          libinput.enable = true;
        })

        (lib.mkIf (config.host.role == "kiosk") {
          enable = true;
          displayManager = {
            autoLogin = {
              user = "${kioskUsername}";
              enable = true;
            };
            defaultSession = "none+openbox";
            lightdm.enable = true;
            job.preStart = ''
              #!/bin/sh
              xrandr --newmode "2560x1080"  230.00  2560 2720 2992 3424 1080 1083 1093 1120 -hsync +vsync
              xrandr --addmode HDMI-1 2560x1080
              xrandr --output HDMI-1 --mode 2560x1080
            '';
          };

          layout = "us";
          libinput.enable = true;

        })
      ];
    }];

    xdg = {
      portal = mkIf (config.host.role != "kiosk") {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
      };
    };
  };
}