{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    container = {
      llng-handler = {
        enable = true;
        logship = "false";
        monitor = "true";
      };
      restic = {
        enable = true;
        logship = "false";
        monitor = "true";
      };
      socket-proxy = {
        enable = true;
        logship = "false";
        monitor = "true";
      };
      traefik = {
        enable = true;
        logship = "false";
        monitor = "true";
      };
      unbound = {
        enable = true;
        logship = "false";
        monitor = "true";
      };
      zabbix-proxy = {
        enable = true;
        logship = "false";
        monitor = "true";
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
          port = 9994;
        };
      };
      wired = {
       enable = true;
       type = "dynamic";
       mac = "02:00:17:01:92:94";
      };
    };
    role = "server";
    service = {
      zabbix_agent = {
        enable = true;
        listenIP = "10.121.15.63";
        serverActive = "10.121.15.63:10051";
      };
    };
    user = {
      root.enable = true;
      dave.enable = true;
    };
  };

  services = {
    qemuGuest.enable = true;
  };
}
