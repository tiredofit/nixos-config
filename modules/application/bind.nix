{config, lib, pkgs, ...}:

let
  cfg = config.host.application.bind;
in
  with lib;
{
  options = {
    host.application.bind = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables name resolution tools";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bind
    ];
  };
}