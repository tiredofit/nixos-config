{config, lib, pkgs, ...}:

let
  cfg = config.host.application.lsof;
in
  with lib;
{
  options = {
    host.application.lsof = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables listing of open files";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lsof
    ];
  };
}