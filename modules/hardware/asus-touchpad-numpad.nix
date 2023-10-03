{ config, lib, pkgs, ... }:
let
  cfg = config.hardware.asus-touchpad-numpad;

in
  with lib;
{}
  options = {
    host.hardware.asus-touchpad-numpad = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables numpad/touchpad support";
      };
      package = mkOption {
        type = types.package;
        description = "Package to use as touchpad driver";
      };
      model = mkOption {
        type = types.str;
        description = "Model of the touchpad.";
      };
    };
  };

  config = mkIf cfg.enable {
    hardware.i2c.enable = true;

    systemd.services.asus-touchpad-numpad = {
      description =
        "Activate Numpad inside the touchpad with top right corner switch";
      script = ''
        ${cfg.package}/bin/asus_touchpad.py ${cfg.model}
      '';
      path = [ pkgs.i2c-tools ];
      after = [ "display-manager.service" ];
      wantedBy = [ "graphical.target" ];
    };
  };
}
