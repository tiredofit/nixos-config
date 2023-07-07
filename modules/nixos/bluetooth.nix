{ config, pkgs, ... }:

{

  # enable bluetooth & gui paring tools - blueman
  # or you can use cli:
    # $ bluetoothctl
    # [bluetooth] # power on
    # [bluetooth] # agent on
    # [bluetooth] # default-agent
    # [bluetooth] # scan on
    # ...put device in pairing mode and wait [hex-address] to appear here...
    # [bluetooth] # pair [hex-address]
    # [bluetooth] # connect [hex-address]
    # Bluetooth devices automatically connect with bluetoothctl as well:
    # [bluetooth] # trust [hex-address]

  services.blueman.enable = true;

  environment.persistence."/persist" = {
    hideMounts = true ;
    directories = [
      "/var/lib/bluetooth"               # Bluetooth
    ];
  };
}
