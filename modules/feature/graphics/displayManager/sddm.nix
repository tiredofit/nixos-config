{ config, lib, pkgs, ... }:
with lib;
let
  graphics = config.host.feature.graphics;
  displayManager = config.host.feature.displayManager.sddm;
  wayland =
    if (graphics.backend == "wayland")
    then true
    else false;
in

{
  config = mkIf (graphics.enable && graphics.displayManager.manager == "sddm") {
    services = {
      displayManager = {
        sddm = {
          enable = mkDefault true;
          wayland.enable = mkDefault wayland;
          theme = "chili";
        };
      };
    };

    # catpuccin-sddm-corners, chili, elarun,. Elegant, maldives, maya, where_is_my_sddm_theme
    environment = {
      systemPackages = with pkgs; [
        #catppuccin-sddm-corners
        #elegant-sddm
        sddm-chili-theme
        #where-is-my-sddm-theme
      ];
    };
  };
}
