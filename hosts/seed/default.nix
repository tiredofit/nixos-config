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
      encryption.enable = false;
      impermanence.enable = true;
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "intel";
      raid.enable = true;
    };
    container = {
      restic = {
        enable = true;
        logship = "false";
        monitor = "false";
      };
      socket-proxy = {
        enable = true;
        logship = "false";
        monitor = "false";
      };
      traefik = {
        enable = true;
        logship = "false";
        monitor = "false";
      };
      unbound = {
        enable = true;
        logship = "false";
        monitor = "false";
      };
    };
    network = {
      hostname = "seed";
      wired = {
       enable = true;
       type = "static";
       ip = "149.56.29.182/24";
       gateway = "149.56.29.254";
       mac = "a8:a1:59:c2:28:e6";
      };

    };
    role = "server";
    user = {
      root.enable = true;
      dave.enable = true;
    };
  };
}
