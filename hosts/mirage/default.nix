{ config, lib, pkgs, ...}: {

  imports = [
    #../../modules/hardware/cpu/apple.nix
    ./disks.nix
    ../common
  ];

  host = {
    container = {
      postfix-relay = {
        enable = true;
        logship = false;
        monitor = false;
        ports = {
          smtp = {
            enable = true;
            host = 25;
            container = 25;
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
          submission = {
            enable = true;
            host = 587;
            container = 587;
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
        };
      };
      restic = {
        enable = true;
        logship = false;
        monitor = false;
      };
      socket-proxy = {
        enable = true;
        logship = false;
        monitor = false;
      };
      traefik = {
        enable = true;
        logship = false;
        monitor = false;
        ports = {
          http = {
            enable = false;
            method = "interface";
            excludeInterfaces = [ "lo" ];
            excludeInterfacePattern = "docker|veth|br-";
          };
          https = {
            enable = true;
            method = "interface";
            excludeInterfaces = [ "lo" ];
            excludeInterfacePattern = "docker|veth|br-";
          };
          http3 = {
            enable = true;
            method = "interface";
            excludeInterfaces = [ "lo" ];
            excludeInterfacePattern = "docker|veth|br-";
          };
        };
      };
      traefik-internal = {
        enable = true;
        logship = false;
        monitor = false;
        ports = {
          http = {
            enable = false;
            host = 80;
            container = 80;
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
          https = {
            enable = true;
            host = 443;
            container = 443;
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
          http3 = {
            enable = true;
            host = 443;
            container = 443;
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
        };
      };
    };
    filesystem = {
      encryption.enable = false;
      impermanence.enable = true;
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "apple";
      wireless.enable = true;
    };
    network = {
      hostname = "mirage";
      interfaces = {
        enp0 = {
          match = {
            mac = "a4:77:f3:00:db:de";
          };
        };
      };
      networks = {
        enp0 = {
          type = "dynamic";
        };
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
      herald = {
        enable = true;
      };
      zeroplex = {
        enable = true;
      };
    };
    user = {
      root.enable = lib.mkDefault true;
      dave.enable = lib.mkDefault true;
    };
  };
}
