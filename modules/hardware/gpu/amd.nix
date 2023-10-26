{ config, lib, pkgs, ... }:
with lib;
let
  device = config.host.hardware ;
in {
  config = mkIf (device.gpu == "amd" || device.gpu == "hybrid-amd" || device.gpu == "integrated-amd")  {
    boot = lib.mkMerge [
      (lib.mkIf (lib.versionOlder pkgs.linux.version "6.1") {
        initrd.kernelModules = ["amdgpu"];
        kernelModules = ["amdgpu"];
        kernelPackages = pkgs.linuxPackages_latest;
        kernelParams = mkIf device.gpu == "integrated-amd" [
          "amdgpu.sg_display=0"];
      })

      (lib.mkIf (lib.versionAtLeast pkgs.linux.version "6.2") {
        initrd.kernelModules = ["amdgpu"];
        kernelModules = ["amdgpu"];
        kernelParams = mkIf device.gpu == "integrated-amd" [
          "amdgpu.sg_display=0"];
      })
    ];

    hardware.opengl.extraPackages = with pkgs; [
      amdvlk
      rocmPackages.clr
      rocmPackages.clr.icd
    ];

    services.xserver.videoDrivers = ["amdgpu"];
  };
}
