{ config, pkgs, ... }:

{
  services.blueman.enable = true;
  hardware.bluetooth.enable = true;

  environment.persistence."/persist" = {
    hideMounts = true ;
    directories = [
      "/var/lib/bluetooth"               # Bluetooth
    ];
  };
}
