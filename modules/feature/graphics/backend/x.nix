{ config, lib, pkgs, specialArgs, ... }:
with lib;
let
  inherit (specialArgs) kioskUsername kioskURL;
  autostart = ''
    #!${pkgs.bash}/bin/bash

    xset s off -dpms &
    xrandr > /tmp/xrandr.log &
    ${pkgs.firefox}/bin/firefox --kiosk ${kioskURL} &
  '';

  inherit (pkgs) writeScript;

  graphics = config.host.feature.graphics;
in {
  config = mkIf (graphics.enable && graphics.backend == "x") {
    environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw

    programs = mkIf (config.host.role != "kiosk") {
      dconf.enable = true;
      seahorse.enable = true;
    };

    security = mkIf (config.host.role != "kiosk") {
      pam = {
        services.gdm.enableGnomeKeyring = true;
      };
      polkit = {
        enable = true;
      };
    };

    services = lib.mkMerge [
    {
      gvfs = (lib.mkIf (config.host.role != "kiosk") {
        enable = true;
      });

      gnome.gnome-keyring = (lib.mkIf (config.host.role != "kiosk") {
        enable = true;
      });

      xserver = lib.mkMerge [
        (lib.mkIf (config.host.role != "kiosk") {
          enable = true;
          desktopManager = {
            xterm.enable = false;
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
#
          layout = "us";
          libinput.enable = true;
          windowManager.openbox.enable = true;
        })
      ];
    }];

    # Overlay to set custom autostart script for openbox
    nixpkgs = mkIf (config.host.role == "kiosk") {
      overlays = with pkgs; [
        (_self: super: {
          openbox = super.openbox.overrideAttrs (_oldAttrs: rec {
            postFixup = ''
              ln -sf /etc/openbox/autostart $out/etc/xdg/openbox/autostart
            '';
          });
        })
      ];
    };

    # By defining the script source outside of the overlay, we don't have to
    # rebuild the package every time we change the startup script.
    environment.etc."openbox/autostart" = mkIf (config.host.role == "kiosk") {
      source = writeScript "autostart" autostart;
    };
  };
}
