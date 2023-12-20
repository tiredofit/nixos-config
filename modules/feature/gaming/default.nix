{config, lib, pkgs, ...}:

let
  cfg = config.host.feature.gaming;
in
  with lib;
{
  imports = [
    ./heroic
    ./steam
  ];

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