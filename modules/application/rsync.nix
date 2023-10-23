{config, lib, pkgs, ...}:

let
  cfg = config.host.application.rsync;
in
  with lib;
{
  options = {
    host.application.rsync = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables remote syncing tool";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      rsync
    ];

    ## TODO Add bash aliases
  };
}