{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    inputs.nur.nixosModules.nur
    ./disks.nix
    ../common
  ];

  host = {
    feature = {
    };
    filesystem = {
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "amd";
    };
    network = {
      hostname = "minimal-template";
      wired.enable = false;             # This line can be removed if not using wired networking
    };
    role = "minimal";
    user = {
      root.enable = true;
    };
  };
}
