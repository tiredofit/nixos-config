{ config, lib, pkgs, ... }:
with lib;
let
  graphics = config.host.feature.graphics;
  autostart = ''
    #!${pkgs.bash}/bin/bash

    xset s off -dpms &
    xrandr > /tmp/xrandr.log &
    ${pkgs.firefox}/bin/firefox --kiosk ${kioskURL} &
  '';
  wayland =
    if (graphics.backend == "wayland")
    then true
    else false;
in

{
  config = mkIf (graphics.enable && graphics.displayManager.manager == "openbox") {
    services = {
      xserver = {
        displayManager = {

        };
      };
    };
  };
}
