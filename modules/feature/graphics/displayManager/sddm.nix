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
  config = mkIf (graphics.enable && graphics.displayManager == "sddm")) {
    services = {
      xserver = {
        displayManager = {
          sddm = {
            enable = mkDefault true;
            wayland.enable = mkDefault wayland;
          };
        };
      };
    };
  };
}
