{config, lib, pkgs, ...}:

let
  cfg = config.host.application.binutils;
in
  with lib;
{
  options = {
    host.application.binutils = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables binutils";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      binutils
    ];
  };
}