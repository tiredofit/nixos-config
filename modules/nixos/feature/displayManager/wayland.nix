{ config, lib, ... }:
with lib;
let
  displayManager = config.host.feature.displayManager.server ;
in {
  config = mkIf (displayManager == "wayland") {

  };
}