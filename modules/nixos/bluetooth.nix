{ config, pkgs, ... }:

{
  services.blueman.enable = true;
  hardware.bluetooth.enable = true;

  hostoptions.impermanence.directories = [
    "/var/lib/bluetooth"               # Bluetooth
  ];
}
