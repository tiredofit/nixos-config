{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    container = {
      clamav = {
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
      cloudflare-companion = {
        enable = true;
        logship = "true";
        monitor = "false";
      };
      unbound = {
        enable = true;
        monitor = "true";
        logship = "false";
      };
      zabbix-proxy = {
        enable = false;
        logship = "false";
        monitor = "false";
      };
    };
    feature = {
    };
    filesystem = {
      encryption.enable = true;
      impermanence.enable = true;
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "amd";
      raid.enable = true;
    };
    network = {
      hostname = "expedition";
      wired = {
       enable = true;
       type = "static";
       ip = "51.79.77.189/24";
       gateway = "51.79.77.254";
       mac = "d8:5e:d3:e9:10:45";
      };
      vpn = {
        zerotier = {
          enable = true;
          networks = [
            "/var/run/secrets/zerotier/networks"
          ];
          port = 9993;
        };
      };
    };
    role = "server";
    service = {
      vscode_server.enable = true;
      zabbix_agent = {
        enable = true;
        listenIP = "10.121.15.109";
        serverActive = "10.121.15.109:10051";
      };
    };
    user = {
      root.enable = true;
      dave.enable = true;
    };
  };
}
