{ config, inputs, lib, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  fileSystems = {
    "/mnt/media" = {
      device = "/dev/disk/by-uuid/9c3cfc7b-f660-44eb-9c60-d32342cdf174";
      fsType = "btrfs";
      options = [ "compress=zstd" "noatime" "nofail" ];
    };
  };

  host = {
    container = {
      coredns = {
        enable = false;
        logship = false;
        monitor = false;
        ports = {
          tcp = {
            enable = true;
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
          udp = {
            enable = true;
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
        };
      };
      postfix-relay = {
        enable = false;
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
    filesystem = {
      encryption.enable = false;
    };
    hardware = {
      cpu = "vm-amd";
    };
    role = "server";
    service = {
      syncthing.enable = true;
      vscode_server.enable = lib.mkForce false;
    };
    network = {
      hostname = "enigma";
      interfaces = {
        lan1337 = {
          match = {
            mac = "52:54:00:b9:02:e2";
          };
        };
      };
      networks = {
        lan1337 = {
          match = {
            name = "lan1337";
          };
          type = "static";
          ip = "10.60.137.5/24";
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
    service = {
      herald = {
        enable = true;
      };
      zeroplex = {
        enable = true;
      };
    };
    user = {
      dave.enable = true;
      root.enable = false;
    };
  };

  networking.firewall = {
    enable = true;  # Firewall is enabled by default
    allowedTCPPorts = [ 8384 ];  # Add your TCP ports here
    allowedUDPPorts = [8384 ];  # Add UDP ports if needed
  };


}
