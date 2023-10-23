{config, lib, pkgs, ...}:

let
  cfg = config.host.application.inetutils;
in
  with lib;
{
  options = {
    host.application.inetutils = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables various internet utilities";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      inetutils
    ];
  };
}