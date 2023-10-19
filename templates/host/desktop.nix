{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    inputs.nur.nixosModules.nur
    ./disks.nix
    ../common/global
  ];

  host = {
    feature = {
      graphics = {
        enable = true;
        backend = "x";
      };
    };
    filesystem = {
      encryption.enable = true;   # This line can be removed if not needed as it is already default set by the role template
      impermanence.enable = true; # This line can be removed if not needed as it is already default set by the role template
      swap = {
        partition = "disk/by-label/swap";
      };
    };
    hardware = {
      cpu = "amd-vm";
      gpu = "integrated-amd";
      raid.enable = false;        # This line can be removed if not needed as it is already default set by the role template
      sound = {
        server = "pulseaudio";
      };
    };
    network = {
      hostname = "desktop-template";
      wired.enable = false;             # This line can be removed if not using wired networking
      wired.type = "dynamic";
      wired.ip = "192.168.123.32/24";   # This line can be removed if not using wired networking and is set to static
      wired.gateway = "192.168.123.1";  # This line can be removed if not using wired networking and is set to static
      wired.mac = "00:01:02:03:04:05";  # This line can be removed if not using wired networking and is set to static
    };
    role = "desktop";
    user = {
      root.enable = true;
    };
  };
}
