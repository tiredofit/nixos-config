{ config, inputs, lib, pkgs, ...}: {

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
      traefik-internal = {
        enable = false;
        logship = "false";
        monitor = "false";
      };
      cloudflare-companion = {
        enable = true;
        logship = "false";
        monitor = "false";
      };
      unbound = {
        enable = true;
        monitor = "false";
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
      bridge = {
        enable = true;
        interfaces = [
          "enp3s0f0"
        ];
      };
      hostname = "entropy";
      wired = {
       enable = true;
       type = "static";
       ip = "148.113.218.18/32";
       gateway = "100.64.0.1";
       mac = "34:5a:60:00:9a:5c";
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
      #zabbix_agent = {
      #  enable = true;
      #  listenIP = "10.121.15.109";
      #  serverActive = "10.121.15.109:10051";
      #};
    };
    user = {
      root.enable = true;
      dave.enable = true;
    };
  };
}
