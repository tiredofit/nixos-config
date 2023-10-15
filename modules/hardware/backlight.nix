{config, lib, pkgs, ...}:

let
  cfg = config.host.hardware.backlight;
in
  with lib;
{
  options = {
    host.hardware.backlight = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables tools for display backlight control";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.light.enable = true;
    services.actkbd = {
      enable = true;
      bindings = [
        { keys = [ 233 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
        { keys = [ 232 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
      ];
    };
  };
}
