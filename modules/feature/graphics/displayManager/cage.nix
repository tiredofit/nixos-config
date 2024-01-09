{ config, inputs, lib, pkgs, specialArgs, ... }:
with lib;
let
  inherit (specialArgs) kioskUsername kioskURL;
  graphics = config.host.feature.graphics;
  wayland =
    if (graphics.backend == "wayland")
    then true
    else false;
in

{
  config = mkIf (graphics.enable && graphics.displayManager.manager == "cage") {
    services = {
      xserver = {
        displayManager = {

        };
      };
    };
  };
}
