{ config, lib, ... }:
with lib;
let
  graphics = config.host.feature.graphics;
  wayland =
    if (config.host.feature.graphics == "wayland")
    then true
    else false;
in

{
  config = mkIf (graphics.enable && graphics.displayManager == "gdm")) {
    services = {
      xserver = {
        displayManager = {
          gdm = {
            enable = mkDefault true;
            wayland = mkDefault wayland;
          };
        };
      };
    };
  };
}
