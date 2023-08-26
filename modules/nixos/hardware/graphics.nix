{config, lib, pkgs, ...}:

let

in
  with lib;
{
  options = {
    host.hardware.graphics.acceleration = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables graphics acceleration";
      };
    };
  };

  config = {
    hardware = {
        opengl = lib.mkIf config.host.hardware.graphics.acceleration.enable {
          enable = true ;
          driSupport = true;
        };
    };
  };
}