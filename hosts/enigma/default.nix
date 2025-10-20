{ inputs, lib, modulesPath, pkgs, ...}: {

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disks.nix
    ../common
  ];

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
      zabbix-proxy = {
        enable = false;
        logship = false;
        monitor = false;
        ports = {
          proxy = {
            enable = true;
            host = 10051;
            container = 10051;
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
        };
      };
    };
    filesystem = {
      encryption.enable = false;
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "vm-intel";
    };
    role = "server";
    service = {
      syncthing.enable = true;
      vscode_server.enable = lib.mkForce false;
    };
    network = {
      hostname = "enigma";
      interfaces = {
        lan = {
          match = {
            mac = "2A:BE:78:89:51:A5";
          };
        };
      };
      networks = {
        lan = {
          match = {
            name = "lan";
          };
          type = "static";
          ip = "192.168.137.5/24";
          gateway = "192.168.137.1";
          dns = [ "192.168.137.1" ];
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

  services.qemuGuest.enable = true;
  #networking.nameservers = [ "192.168.137.1" ];

  #services.resolved = {
  #  enable = lib.mkForce false;
  #  dnssec = "false";
  #  domains = [ "~." ];
  #  fallbackDns = [ "192.168.137.1" ];
  #};
}
