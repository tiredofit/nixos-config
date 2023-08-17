{config, lib, pkgs, ...}:

let
  cfg_bluetooth = config.hostoptions.bluetooth;
in
  with lib;
{
  options = {
    hostoptions.bluetooth = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable Bluetooth";
      };
    };
  };

  config = mkIf cfg_bluetooth.enable {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

    hostoptions.impermanence.directories = mkIf config.hostoptions.impermanence.enable [
      "/var/lib/bluetooth"               # Bluetooth
    ];
  };
}
