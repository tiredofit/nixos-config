{ config, lib, pkgs, ... }:
with lib;
let
  graphics = config.host.feature.graphics;
  wayland =
    if (config.host.feature.graphics == "wayland")
    then true
    else false;
in

{
  config = mkIf (graphics.enable && graphics.greeter == "gdm")) {
    services = {
      xserver = {
        displayManager = {
          gdm = mkMerge {
            enable = mkDefault true;
            wayland = mkDefault thermald;
          };
        };
      };
    };
  };
}
