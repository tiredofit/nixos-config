{ config, pkgs, specialArgs, ...}:
let
  inherit (specialArgs) kioskUsername kioskURL;
  autostart = ''
    #!${pkgs.bash}/bin/bash

    xset s off -dpms &
    xrandr > /tmp/xrandr.log &
    ${pkgs.firefox}/bin/firefox --kiosk ${kioskURL} &
  '';

  inherit (pkgs) writeScript;
in
{

  environment.systemPackages = with pkgs; [
    firefox
    chromium
  ];

  services.xserver = {
    enable = true;

    displayManager = {
      autoLogin = {
        user = "${kioskUsername}";
        enable = true;
      };
      defaultSession = "none+openbox";
      lightdm.enable = true;
    }

    layout = "us";
    libinput.enable = true;
    windowManager.openbox.enable = true;
  };

  services.xserver.displayManager.job.preStart = ''
    #!/bin/sh
    xrandr --newmode "2560x1080"  230.00  2560 2720 2992 3424 1080 1083 1093 1120 -hsync +vsync
    xrandr --addmode HDMI-1 2560x1080
    xrandr --output HDMI-1 --mode 2560x1080
  '';
  systemd.services."display-manager".after = [
    "network-online.target"
    "systemd-resolved.service"
  ];

  # Overlay to set custom autostart script for openbox
  nixpkgs.overlays = with pkgs; [
    (_self: super: {
      openbox = super.openbox.overrideAttrs (_oldAttrs: rec {
        postFixup = ''
          ln -sf /etc/openbox/autostart $out/etc/xdg/openbox/autostart
        '';
      });
    })
  ];

  # By defining the script source outside of the overlay, we don't have to
  # rebuild the package every time we change the startup script.
  environment.etc."openbox/autostart".source = writeScript "autostart" autostart;
}
