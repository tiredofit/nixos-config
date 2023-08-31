{config, lib, pkgs, ...}:
  with lib;
{
  options = {
    host.hardware.monitors = mkOption {
      type = with types; listOf str;
      default = [];
      description = "Declare the order of monitors in Window manager configurations";
    };
  };
}
