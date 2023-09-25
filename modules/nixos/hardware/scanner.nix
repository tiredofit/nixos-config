{config, lib, pkgs, ...}:

let
  cfg = config.host.hardware.scanning;
in
  with lib;
{
  options = {
    host.hardware.scanning = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables drivers for scanning documents";
      };
    };
  };

  config = mkIf cfg.enable {
    hardware = {
      sane = {
        enable = true;
        openFirewall = mkDefault false;
        extraBackends = [
          pkgs.hplipWithPlugin
        ];
      };

    };
  };
}
