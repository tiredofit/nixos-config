{ config, lib, pkgs, ... }:
with lib;
let
  device = config.host.hardware ;
  backend = config.host.feature.graphics.backend;
  graphics = config.host.feature.graphics.enable;
in {
  config = mkIf (device.gpu == "amd" || device.gpu == "hybrid-amd" || device.gpu == "integrated-amd")  {
    boot = lib.mkMerge [
      (lib.mkIf (lib.versionAtLeast pkgs.linux.version "6.2") {
        kernelModules = [
          "amdgpu"
        ];
      })
    ];

    #host.feature.boot.kernel.parameters = mkIf (device.gpu == "integrated-amd") [
    #  "amdgpu.sg_display=0"
    #];

    hardware = {
      graphics = {
        extraPackages = with pkgs; [
          amdvlk
          rocmPackages.clr
          rocmPackages.clr.icd
        ];
      };
    };

    environment = {
      sessionVariables = mkMerge [
        (mkIf (graphics) {
          LIBVA_DRIVER_NAME = "radeonsi";
        })

        (mkIf ((graphics) && (backend == "wayland")) {
          WLR_NO_HARDWARE_CURSORS = "1";
        })
      ];
    };

    services.xserver.videoDrivers = (mkIf ((graphics) && (backend == "x"))) [
      "amdgpu"
    ];
  };
}
