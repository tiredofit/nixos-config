{config, lib, pkgs, ...}:
with lib;
{
  imports = [
    ./cpu/amd.nix
    ./cpu/intel.nix
  ];

  options = {
    host.hardware = {
      cpu = mkOption {
        type = types.str;
        default = null;
        description = "Type of CPU: intel, vm-intel, amd, vm-amd";
      };
    };
  };
}