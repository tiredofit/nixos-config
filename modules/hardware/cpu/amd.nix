{ config, lib, ... }:
with lib;
let
  kver = config.boot.kernelPackages.kernel.version;
  device = config.host.hardware ;
in {
  config = mkIf (device.cpu == "amd" || device.cpu == "vm-amd") {
   boot.blacklistedKernelModules = [ "k10temp" ];
   boot.extraModulePackages = [ config.boot.kernelPackages.zenpower ];
   boot.kernelModules = [ "zenpower" ]; 
   
   hardware.cpu.amd.updateMicrocode = true;

    host.feature.boot.kernel = {
      modules = [
        "kvm-amd"
      ];
      parameters = [
        "amd_pstate=active"
      ];
    };

    nixpkgs = {
      hostPlatform = "x86_64-linux";
    };
  };
}
