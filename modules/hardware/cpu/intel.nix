{ config, lib, pkgs, ... }:
let
  device = config.host.hardware ;
in
  with lib;
{
  config = mkIf (device.cpu == "intel" || device.cpu == "vm-intel") {
    hardware.cpu.intel.updateMicrocode = true;

    boot = {
      #kernelModules = ["kvm-intel"];
      #kernelParams = ["i915.fastboot=1" "enable_gvt=1"];
    };

    host.feature.boot.kernel = {
      modules = [
        "kvm-intel"
      ];
      parameters = [
        "enable_gvt=1"
        "i915.fastboot=1"
      ];
    };

    environment.systemPackages = with pkgs; [
      intel-gpu-tools
    ];

    nixpkgs.hostPlatform = "x86_64-linux";
  };
}
