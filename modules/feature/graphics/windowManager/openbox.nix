{ config, lib, pkgs, ... }:
with lib;
let
  graphics = config.host.feature.graphics;
in

{
  config = mkIf (graphics.enable && graphics.windowManager.manager == "openbox") {
    services = {
      xserver = {
        windowManager = {
          openbox.enable = mkForce true;
        };
      };
    };
  };
}
