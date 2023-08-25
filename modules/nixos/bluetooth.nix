{config, lib, pkgs, ...}:

let
  cfg = config.host.hardware.bluetooth;
in
  with lib;
{
  options = {
    host.hardware.bluetooth = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable Bluetooth";
      };
    };
  };

  config = mkIf cfg.enable {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

    hostoptions.impermanence.directories = mkIf config.hostoptions.impermanence.enable [
      "/var/lib/bluetooth"               # Bluetooth
    ];
  };
}
