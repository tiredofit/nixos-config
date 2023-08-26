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
      acceleration = {
        enable = mkOption {
          default = false;
          type = with types; bool;
          description = "Enables graphics acceleration";
        };
      };
      displayServer = mkOption {
        type = types.str;
        default = null;
        description = "Display Server: x or wayland";
      };
      gpu = mkOption {
        type = types.str;
        default = null;
        description = "Type of GPU: hybrid-amd, hybrid-nvidia, integrated-amd, intel,  nvidia";
      };
    };
  };

  config = {
    hardware = {
        opengl = lib.mkIf ( config.host.hardware.graphics.acceleration.enable && config.host.hardware.graphics.enable ){
          enable = true ;
          driSupport = true;
          driSupport32Bit = true;
        };
    };
  };
}