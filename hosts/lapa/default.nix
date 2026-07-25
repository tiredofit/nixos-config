{ config, inputs, lib, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    feature = {
    };
    filesystem = {
      encryption.enable = false;
      impermanence.enable = true;
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "amd";
      raid.enable = false;
    };
    network = {
      manager = "both";
      hostname = "lapa";
    };
    role = "server";
    user = {
      tttttt.enable = lib.mkDefault true;
      root.enable = lib.mkDefault true;
      dave.enable = lib.mkDefault true;
    };
  };
}
