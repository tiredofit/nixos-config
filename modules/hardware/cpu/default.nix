{config, lib, pkgs, ...}:
with lib;
{
  imports = [
    ./ampere.nix
    ./amd.nix
    ./intel.nix
  ];

  options = {
    host.hardware = {
      cpu = mkOption {
        type = types.enum ["amd" "ampere" "intel" "vm-amd" "vm-intel" null];
        default = null;
        description = "Type of CPU: intel, vm-intel, amd, vm-amd";
      };
    };
  };
}