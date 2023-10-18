{ config, lib, ... }:
with lib;
let
  kver = config.boot.kernelPackages.kernel.version;
  device = config.host.hardware ;
in {
  config = mkIf (device.cpu == "amd" || device.cpu == "vm-amd") {
    hardware.cpu.amd.updateMicrocode = true;
    boot = lib.mkMerge [
      (lib.mkIf
        (
          (lib.versionAtLeast kver "5.17")
          && (lib.versionOlder kver "6.1")
        )
        {
          kernelParams = [ "initcall_blacklist=acpi_cpufreq_init" ];
          kernelModules = [ "amd-pstate" "kvm-amd" ];
        })
      (lib.mkIf
        (
          (lib.versionAtLeast kver "6.1")
          && (lib.versionOlder kver "6.3")
        )
        {
          kernelParams = [ "amd_pstate=passive" "kvm-amd" ];
        })
      (lib.mkIf (lib.versionAtLeast kver "6.3") {
        kernelParams = [ "amd_pstate=active" "kvm-amd" ];
      })
    ];
  nixpkgs.hostPlatform = "x86_64-linux";
  };
}