{config, lib, pkgs, ...}:

let
  cfg = config.host.application.mtr;
in
  with lib;
{
  options = {
    host.application.mtr = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables visual network tracerouting";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      mtr
    ];
  };
}