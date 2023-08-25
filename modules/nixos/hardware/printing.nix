{config, lib, pkgs, ...}:

let
  cfg = config.host.hardware.printing;
in
  with lib;
{
  options = {
    host.hardware.printing = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables and drivers for printing";
      };
    };
  };

  config = mkIf cfg.enable {
    services = {
      printing = {
        enable = true;
        drivers = with pkgs;
        [
          hplip
        ];
      };
    };

    host.feature.impermanence.directories = mkIf config.host.feature.impermanence.enable [
      "/var/lib/cups"          # CUPS
    ];
  };
}
