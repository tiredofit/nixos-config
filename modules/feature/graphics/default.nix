{config, lib, pkgs, ...}:
  with lib;
{
  imports = [
    ./backend
    ./displayManager
    ./windowManager
  ];

  options = {
    host.feature.graphics = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables Graphics Support";
      };
      acceleration = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables graphics acceleration";
      };
      backend = mkOption {
        type = types.enum ["x" "wayland" null];
        default = null;
        description = "Backend of displayManager";
      };
      monitors = mkOption {
        type = with types; listOf str;
        default = [];
        description = "Declare the order of monitors in Window manager configurations";
      };
    };
  };

  config = {
    hardware = {
      opengl = mkIf ((config.host.feature.graphics.enable) && (config.host.feature.graphics.acceleration)) {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
      };
    };
  };
}
