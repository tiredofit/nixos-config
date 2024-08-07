{config, lib, pkgs, ...}:

let
  cfg = config.host.filesystem.bcachefs;
in
  with lib;
{
  options = {
    host.filesystem.bcachefs = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables settings for BCacheFS";
      };
    };
  };

  config = mkIf cfg.enable {
    boot = {
      supportedFilesystems = [
        "bcachefs"
      ];
    };
  };
}
