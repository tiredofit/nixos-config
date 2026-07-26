{ config, inputs, lib, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    container = {
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
            host = 80;
            container = 80;
            method = "interface";
            excludeInterfaces = [ "lo" ];
            excludeInterfacePattern = "docker|veth|br-";
          };
          https = {
            enable = true;
            host = 443;
            container = 443;
            method = "interface";
            excludeInterfaces = [ "lo" ];
            excludeInterfacePattern = "docker|veth|br-";
          };
          http3 = {
            enable = true;
            host = 443;
            container = 443;
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
    feature = {
      nix-ld.enable = true;
    };
    filesystem = {
      encryption.enable = false;
    };
    hardware = {
      cpu = "vm-amd";
    };
    network = {
      hostname = "lapa";
      interfaces = {
        lan1337 = {
          match = {
            mac = "52:54:00:c3:e4:91";
          };
        };
      };
      networks = {
        lan1337 = {
          match = {
            name = "lan1337";
          };
          type = "static";
          ip = "10.60.137.6/24";
          gateway = "10.60.137.1";
          dns = [ "10.60.137.1" ];
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
      vscode_server.enable = lib.mkForce false;
      herald = {
        enable = true;
      };
      zeroplex = {
        enable = true;
      };
    };
    user = {
      tttttt.enable = lib.mkDefault true;
      root.enable = lib.mkDefault true;
      dave.enable = lib.mkDefault true;
    };
  };
}
