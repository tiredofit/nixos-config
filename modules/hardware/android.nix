{config, lib, pkgs, ...}:

let
  cfg = config.host.hardware.android;
in
  with lib;
{
  options = {
    host.hardware.android = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable Android tools to support transfer and debugging";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.adb.enable = true;

    environment.systemPackages = with pkgs; [
      android-tools
      android-udev-rules
    ];
  };
}
