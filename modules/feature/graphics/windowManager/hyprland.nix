{ config, inputs, lib, pkgs, ... }:
with lib;
let
  graphics = config.host.feature.graphics;
in

{
  config = mkIf (graphics.enable && graphics.windowManager.manager == "hyprland") {
    programs = {
      hyprland = {
        enable = mkDefault true;
        #package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      };
    };

    #xdg.portal = {
    #  enable = true;
    #  extraPortals = with pkgs;  [
    #    xdg-desktop-portal
    #    xdg-desktop-portal-gtk
    #    xdg-desktop-portal-wlr
    #  ];
    #  wlr = {
    #    enable = true;
    #    settings = {
    #      screencast = {
#
    #      };
    #    };
    #  };
    #};
  };
}
