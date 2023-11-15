{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    inputs.nur.nixosModules.nur
    ./disks.nix
    ../common
  ];

  host = {
    container = {
      llng-handler = {
        enable = true;
        logship = "false";
        monitor = "false";
      };
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
    feature = {
    };
    filesystem = {
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "ampere";
      raid.enable = false;
    };
    network = {
      hostname = "tentacle";
      vpn = {
        zerotier = {
          enable = true;
          networks = [
            "/var/run/secrets/zerotier/networks"
          ];
        };
      };
      wired = {
       enable = true;
       type = "dynamic";
       mac = "02:00:17:01:92:94";
      };
    };
    role = "server";
    user = {
      root.enable = true;
      dave.enable = true;
    };
  };

  services = {
    qemuGuest.enable = true;
  };
}
