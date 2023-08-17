{config, lib, pkgs, ...}:

let
  cfg_printing = config.hostoptions.printing;
in
  with lib;
{
  options = {
    hostoptions.printing = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables and drivers for printing";
      };
    };
  };

  config = mkIf cfg_printing.enable {
    services = {
      printing = {
        enable = true;
        drivers = with pkgs;
        [
          hplip
        ];
      };
    };

    hostoptions.impermanence.directories = mkIf config.hostoptions.impermanence.enable [
      "/var/lib/cups"          # CUPS
    ];
  };
}
