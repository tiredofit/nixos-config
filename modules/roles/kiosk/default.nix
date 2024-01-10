{ config, lib, modulesPath, pkgs, specialArgs, ... }:
let
  inherit (specialArgs) kioskUsername kioskURL;
  inherit (pkgs) writeScript;
  role = config.host.role;
  autostart = ''
    #!${pkgs.bash}/bin/bash

    #xset s off -dpms &
    #xrandr > /tmp/xrandr.log &
    ${pkgs.firefox}/bin/firefox --kiosk ${kioskURL} &
  '';
in
  with lib;
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")

  ];

  ## TODO Need to come up with a better naming structure as this doesn't support nested options
  #options = {
  #  host.role.kiosk.browser = mkOption {
  #    type = types.enum ["firefox" "chromium"];
  #    default = "firefox";
  #    description = "URL to visit on browser";
  #    };
  #  host.role.kiosk.url = mkOption {
  #    type = types.str;
  #    default = "https://tiredofit.ca";
  #    description = "URL to visit on browser";
  #  };
  #};

  config = mkIf (role == "kiosk") {
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
    environment.etc."openbox/autostart" = mkIf (config.host.feature.graphics.backend == "x") {
      source = writeScript "autostart" autostart;
    };

    host = {
      feature = {
        boot = {
          efi.enable = mkDefault false;
          graphical.enable = mkDefault false;
        };
        fonts = {
          enable = mkDefault true;
        };
        graphics = {
          enable = mkDefault true;
          acceleration = mkDefault true;
          backend = mkDefault "x";
          displayManager = {
            autoLogin = {
              enable = mkDefault true;
              user = "${kioskUsername}";
            };
            manager = mkIf (config.host.feature.graphics.backend == "x") "lightdm";
          };
          windowManager = mkMerge [
            (mkIf (config.host.feature.graphics.backend == "cage") {
              manager = "wayland";
            })
            (mkIf (config.host.feature.graphics.backend == "x") {
              manager = "openbox";
            })
          ];
        };
        powermanagement = {
          enable = mkDefault false;
        };
      };
      filesystem = {
        btrfs.enable = mkDefault false;
        encryption.enable = mkDefault false;
        impermanence = {
          enable = mkDefault false;
          directories = [

          ];
        };
        swap = {
          enable = mkDefault false;
        };
      };
      hardware = {
        bluetooth.enable = mkDefault false;
        printing.enable = mkDefault false;
        raid.enable = mkDefault false;
        scanning.enable = mkDefault false;
        sound.enable = mkDefault false;
        webcam.enable = mkDefault true;
        wireless.enable = mkDefault true;
        yubikey.enable = mkDefault true;
      };
      network = {
        firewall.fail2ban.enable = mkDefault false;
      };
      service = {
        logrotate.enable = mkDefault true;
        ssh = {
          enable = mkDefault true;
          harden = mkDefault true;
        };
      };
    };

    powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

    programs = {
      dconf.enable = mkForce false;
      seahorse.enable = mkForce false;
    };

    security = {
      pam = {
        services.gdm.enableGnomeKeyring = mkForce false;
      };
      polkit = {
        enable = mkForce false;
      };
    };

    services = {
      cage = {
        user = "${kioskUsername}";
        program = "${pkgs.firefox}/bin/firefox -kiosk -private-window ${kioskURL}";
      };

      gvfs.enable = mkForce false;
      gnome.gnome-keyring.enable = mkForce false;

      xserver = mkMerge [
        (mkIf (config.host.feature.graphics.backend == "x") {
          enable = true;
          desktopManager = {
            xterm.enable = MkForce false;
          };

          displayManager = {
            defaultSession = mkDefault "none+openbox";
          };

          layout = "us";
          libinput.enable = mkForce true;

          #windowManager = {
          #  openbox.enable = mkForce true;
          #};

          #job.preStart = ''
          #  #!/bin/sh
          #  xrandr --newmode "2560x1080"  230.00  2560 2720 2992 3424 1080 1083 1093 1120 -hsync +vsync
          #  xrandr --addmode HDMI-1 2560x1080
          #  xrandr --output HDMI-1 --mode 2560x1080
          #'';
        })

        (mkIf (config.host.feature.graphics.backend == "wayland") {
          enable = true;
          desktopManager = {
            xterm.enable = MkForce false;
          };

          layout = "us";
          libinput.enable = mkForce true;

          #job.preStart = ''
          #  #!/bin/sh
          #  xrandr --newmode "2560x1080"  230.00  2560 2720 2992 3424 1080 1083 1093 1120 -hsync +vsync
          #  xrandr --addmode HDMI-1 2560x1080
          #  xrandr --output HDMI-1 --mode 2560x1080
          #'';
         })
        ];
      };
    };


}