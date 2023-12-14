{config, lib, pkgs, ...}:

let
  cfg = config.host.hardware.keyboard;
in
  with lib;
{
  options = {
    host.hardware.keyboard = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable customizable keyboard support";
      };
    };
  };

  config = mkIf cfg.enable {
    hardware.keyboard.qmk.enable = true;

    environment.systemPackages = with pkgs; [
      qmk
      via
    ];
  };
}
