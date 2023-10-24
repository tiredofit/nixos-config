{config, lib, pkgs, ...}:

let
  cfg = config.host.application.busybox;
in
  with lib;
{
  options = {
    host.application.busybox = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables busybox";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      busybox
    ];
  };
}