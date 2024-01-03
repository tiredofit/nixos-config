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
          gutenprint
          hplip
        ];
      };
      # required for network discovery of printers
      avahi = {
        enable = true;
        # resolve .local domains for printers
        nssmdns4 = true;
        # pass avahi port(s) to the firewall
        openFirewall = true;
      };
    };



    host.filesystem.impermanence.directories = mkIf config.host.filesystem.impermanence.enable [
      "/var/lib/cups"          # CUPS
    ];
  };
}
