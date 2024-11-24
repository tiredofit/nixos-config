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
        package = pkgs.hyprland;
        portalPackage = pkgs.xdg-desktop-portal-wlr;
        #package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      };
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      config.common = {
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        #"org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
        #"org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        "org.freedesktop.portal.FileChooser" = [ "xdg-desktop-portal-shana" ];
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-shana
        xdg-desktop-portal-wlr
      ];
    };
  };
}
