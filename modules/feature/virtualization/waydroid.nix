{config, lib, pkgs, ...}:

let
  cfg = config.host.feature.virtualization.waydroid;
in
  with lib;
{
  options = {
    host.feature.virtualization.waydroid = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables Android Emulation";
      };
    };
  };

  config = mkIf (cfg.enable && config.host.feature.graphics.enable && config.host.feature.graphics.backend == "wayland") {
    virtualisation.waydroid.enable = true;

    host.filesystem.impermanence.directories = mkIf (config.host.filesystem.impermanence.enable) [
      "/var/lib/waydroid"                 # Waydroid
    ];
  };
}
