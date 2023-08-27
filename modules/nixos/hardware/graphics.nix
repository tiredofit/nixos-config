{config, lib, pkgs, ...}:

with lib;
{

  imports = [
    ./gpu/amd.nix
    ./gpu/intel.nix
    ./gpu/nvidia.nix
  ];

  options = {
    host.hardware.graphics = {
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
      displayServer = mkOption {
        type = types.enum ["x" "wayland" null];
        default = null;
        description = "Display Server: x or wayland";
      };
      gpu = mkOption {
        type = types.enum ["pi" "amd" "intel" "nvidia" "hybrid-nv" "hybrid-amd" "integrated-amd" null];
        default = null;
        description = "Manufacturer/type of the primary system gpu";
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
        opengl = lib.mkIf ( config.host.hardware.graphics.acceleration && config.host.hardware.graphics.enable ){
          enable = true ;
          driSupport = true;
          driSupport32Bit = true;
        };
    };
  };
}