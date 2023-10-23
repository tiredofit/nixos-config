{config, lib, pkgs, ...}:

let
  cfg = config.host.application.htop;
in
  with lib;
{
  options = {
    host.application.htop = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables htop";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      htop
    ];
  };
}