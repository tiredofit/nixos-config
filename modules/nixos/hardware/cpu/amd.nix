{ config, lib, ... }:
with lib;
let
  device = config.host.hardware ;
in {
  config = mkIf (device.cpu == "amd" || device.cpu == "vm-amd") {
    hardware.cpu.amd.updateMicrocode = true;
    boot.kernelModules = ["kvm-amd"];
  };
}