{ config, lib, pkgs, ... }:
with lib;
let
  graphics = config.host.feature.graphics;
in

{
  config = mkIf (graphics.enable && graphics.windowManager.manager == "cage") {
    services = {
      cage = {
        enable = mkDefault true;
      };
    };
  };
}
