{config, lib, ...}:
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
    # lib.mkIf (lib.versionOlder lib.version "24.11pre")
    # (lib.versionAtLeast lib.version "24.11")

    hardware = {
      #opengl = mkIf ((config.host.feature.graphics.enable) && (config.host.feature.graphics.acceleration)) { ## 24.11 - Rename hardware.opengl. to hardware.graphics.
      #  driSupport = true;      # 24.11 - Remove in favour of enable
      #  driSupport32Bit = true; # 24.11 - Remove in favor of enable 32Bit
      #};
      graphics = mkIf ((config.host.feature.graphics.enable) && (config.host.feature.graphics.acceleration)) {
        enable = true;
        enable32Bit = true;    # 24.11
      };
    };
  };
}
