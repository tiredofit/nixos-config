{config, lib, pkgs, ...}:

let
  cfg = config.host.application.changeme;
in
  with lib;
{
  options = {
    host.application.changeme = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables changeme";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
    ];

    programs.changeme = {

    };

  };
}