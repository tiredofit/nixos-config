{config, lib, pkgs, ...}:

let
  cfg = config.host.service.logrotate;
in
  with lib;
{
  options = {
    host.service.logrotate = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables logrotation";
      };
    };
  };

  config = mkIf cfg.enable {
    services = {
      logrotate = {
        enable = true;
        settings.header = {
          global = mkDefault true;
          priority = mkDefault 1;
          frequency = mkDefault "daily";
          rotate = mkDefault 7;
          dateext = mkDefault true;
          dateformat = mkDefault "-%Y-%m-%d";
          nomail = mkDefault true;
          notifempty = mkDefault true; # TODO - when switching to false this breaks
          missingok = mkDefault true;
          copytruncate = mkDefault true;
          compress = mkDefault true;
          compresscmd = mkDefault "${pkgs.zstd}/bin/zstd";
          compressoptions = mkDefault "-8";
        };
      };
    };
  };
}
