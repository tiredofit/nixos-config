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
      asus-touchpad-numpad = {
        enable = mkOption {
          default = false;
          type = with types; bool;
          description = "Enables numpad/touchpad support";
        };
        model = mkOption {
          type = with types; str;
          default = "m433ia";
          description = "Model of the touchpad.";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = mkIf cfg.asus-touchpad-numpad.enable [
      pkgs.asus-touchpad-numpad
    ];

    hardware.i2c.enable = mkIf cfg.asus-touchpad-numpad.enable true;
    services = {
      xserver.libinput = {
        enable = true;
        mouse = {
          accelProfile = mkDefault "flat";
          accelSpeed = mkDefault "0";
          middleEmulation = mkDefault false;
        };
        touchpad = {
          clickMethod = "clickfinger";
          disableWhileTyping = mkDefault true;
          horizontalScrolling = mkDefault false;
          naturalScrolling = mkDefault false;
          sendEventsMode = mkDefault "enabled";
          tapping = mkDefault true;
        };
      };
    };

    systemd.services.asus-touchpad-numpad = mkIf cfg.asus-touchpad-numpad.enable {
      description = "Activate Numpad inside the touchpad with top right corner switch";
      script = ''
        ${pkgs.asus-touchpad-numpad}/bin/asus_touchpad.py ${cfg.asus-touchpad-numpad.model}
      '';
      path = [ pkgs.i2c-tools ];
      after = [ "display-manager.service" ];
      wantedBy = [ "graphical.target" ];
    };
  };
}
