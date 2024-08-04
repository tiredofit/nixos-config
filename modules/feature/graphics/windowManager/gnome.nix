{ config, inputs, lib, pkgs, ... }:
with lib;
let
  graphics = config.host.feature.graphics;
in

{
  config = mkIf (graphics.enable && graphics.windowManager.manager == "gnome") {
    services = {
      xserver = {
        desktopManager = {
          gnome = {
            enable = true;
          };
        };
      };
    };
  };
}
