{config, lib, pkgs, ...}:

let
  cfg = config.host.application.iftop;
in
  with lib;
{
  options = {
    host.application.iftop = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables network interface measurement";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      iftop
    ];
  };
}