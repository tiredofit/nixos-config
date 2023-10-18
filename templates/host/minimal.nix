{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    inputs.nur.nixosModules.nur
    ./disks.nix
    ../common/global
  ];

  host = {
    feature = {
    };
    filesystem = {
      swap = {
        partition = "disk/by-label/swap";
      };
    };
    hardware = {
      cpu = "amd";
    };
    network = {
      hostname = "minimal-template";
      wired.enable = false;       # This line can be removed if not using wired networking
      type = "dynamic";
      ip = "192.168.123.32/24";   # This line can be removed if not using wired networking and is set to static
      gateway = "192.168.123.1";  # This line can be removed if not using wired networking and is set to static
      mac = "00:01:02:03:04:05";  # This line can be removed if not using wired networking and is set to static
    };
    role = "minimal";
    user = {
      root.enable = true;
    };
  };
}
