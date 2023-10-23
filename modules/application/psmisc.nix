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
        description = "Enables process managment tools";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      psmisc
    ];
  };
}