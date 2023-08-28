{config, lib, pkgs, ...}:

let
  cfg = config.host.hardware.touchpad;
in
  with lib;
{
  options = {
    host.hardware.touchpad = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables touchpad support";
      };
    };
  };

  config = mkIf cfg.enable {
    services = {
      xserver.libinput = {
        enable = true;

        # disable mouse acceleration
        mouse.accelProfile = "flat";
        mouse.accelSpeed = "0";
        mouse.middleEmulation = false;

        # touchpad settings
        touchpad.naturalScrolling = false;
        touchpad.tapping = true;
        touchpad.clickMethod = "clickfinger";
        touchpad.horizontalScrolling = false;
        touchpad.disableWhileTyping = true;
      };
    };
  };
}
