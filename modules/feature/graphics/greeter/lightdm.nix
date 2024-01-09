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
  config = mkIf (graphics.enable && graphics.greeter == "lightdm")) {
    services = {
      xserver = {
        displayManager = {
          lightdm = {
            enable = mkDefault true;
            greeters = {
              slick = {
                enable = mkDefault true;
                theme = {
                  name = mkDefault "Adwaita-Dark";
                };
                cursorTheme = {
                  name = mkDefault "Quintom_Snow";
                  package = mkDefault pkgs.quintom-cursor-theme;
                };
              };
              gtk = {
                  enable = mkDefault false;
              };
            };
          };
        };
      };
    };
  };
}
