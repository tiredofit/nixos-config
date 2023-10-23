{config, lib, pkgs, ...}:

let
  cfg = config.host.application.iotop;
in
  with lib;
{
  options = {
    host.application.iotop = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables IO measurement tools";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      iotop
    ];
  };
}