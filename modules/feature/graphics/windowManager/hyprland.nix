{ config, lib, pkgs, ... }:
with lib;
let
  graphics = config.host.feature.graphics;
in

{
  config = mkIf (graphics.enable && graphics.windowManager.manager == "hyprland") {
    programs = {
      hyprland = {
        enable = mkDefault true;
        package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      };
    };
  };
}
