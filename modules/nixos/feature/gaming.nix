{config, lib, pkgs, ...}:

let
  cfg_steam = config.host.feature.gaming;
in
  with lib;
  eith pkgs;
{
  options = {
    host.feature.gaming = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables gaming support";
      };
    };
  };

  config = mkIf cfg.enable {
  };
}