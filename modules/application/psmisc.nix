{config, lib, pkgs, ...}:

let
  cfg = config.host.application.psmisc;
in
  with lib;
{
  options = {
    host.application.psmisc = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "A set of small useful utilities that use the proc filesystem (such as fuser, killall and pstree)";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      psmisc
    ];
  };
}