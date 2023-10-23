{config, lib, pkgs, ...}:

let
  cfg = config.host.application.pciutils;
in
  with lib;
{
  options = {
    host.application.pciutils = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables toosl for working with hardware devices";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pciutils
    ];
  };
}