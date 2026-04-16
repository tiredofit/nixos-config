{ config, inputs, lib, pkgs, ... }:
with lib;
let
  graphics = config.host.feature.graphics;
in

{
  #config = mkIf (graphics.enable && graphics.windowManager.manager == "niri" {
  config = mkIf (graphics.enable) {
    programs = {
      niri = {
        enable = mkDefault true;
        package = mkDefault pkgs.niri;
        #portalPackage = pkgs.xdg-desktop-portal-hyprland;
        #withUWSM  = mkDefault true;
        #package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      };
    };

    environment.systemPackages = [
      niriswitcher
      nirius
      niri
    ];
  );
}
