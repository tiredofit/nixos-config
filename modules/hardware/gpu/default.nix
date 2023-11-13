{config, lib, pkgs, ...}:
  with lib;
{
  imports = [
    ./amd.nix
    ./intel.nix
    ./nvidia.nix
  ];

  options = {
    host.hardware.gpu = mkOption {
        type = types.enum [ "amd" "intel" "nvidia" "hybrid-nvidia" "hybrid-amd" "integrated-amd" "pi" null];
        default = null;
        description = "Manufacturer/type of the primary system GPU";
    };
  };
}