{ config, lib, pkgs, ... }:
with lib;
let
  device = config.host.hardware ;
in {
  config = mkIf (device.gpu == "amd" || device.gpu == "hybrid-amd" || device.gpu == "integrated-amd")  {
    boot = lib.mkMerge [
      (lib.mkIf (lib.versionAtLeast pkgs.linux.version "6.2") {
        initrd.kernelModules = [
          "amdgpu"
        ];
        kernelModules = [
          "amdgpu"
        ];
        kernelParams = mkIf (device.gpu == "integrated-amd")
        [
          "amdgpu.sg_display=0"
        ];
      })
    ];

    hardware.graphics.extraPackages = with pkgs; [
      amdvlk
      rocmPackages.clr
      rocmPackages.clr.icd
    ];

    services.xserver.videoDrivers = [
      "amdgpu"
    ];
  };
}
