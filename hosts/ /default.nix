{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.nur.nixosModules.nur
    ./disks.nix
    ../common/global
  ];

  host = {
    feature = {
    };
    filesystem = {
      encryption.enable = false;   # This line can be removed if not needed as it is already default set by the role template
      impermanence.enable = true; # This line can be removed if not needed as it is already default set by the role template
      swap = {
        partition = "disk/by-label/swap";
      };
    };
    hardware = {
      cpu = "amd";
      raid.enable = true;        # This line can be removed if not needed as it is already default set by the role template
    };
    network = {
      hostname = " ";
      wired.enable = true;        # This line can be removed if not using wired networking
      type = "dynamic";
      ip = "192.168.123.32/24";   # This line can be removed if not using wired networking and is set to static
      gateway = "192.168.123.1";  # This line can be removed if not using wired networking and is set to static
      mac = "00:01:02:03:04:05";  # This line can be removed if not using wired networking and is set to static
    };
    role = "server";
    user = {
      root.enable = true;
    };
  };
}
