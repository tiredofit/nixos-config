{ inputs, lib, pkgs, ...}: {

  imports = [
    ./hardware-configuration.nix
    ../common
  ];

  fileSystems = {
      "/mnt/media".options = [ "compress=zstd" "noatime"  ];
  };

  host = {
    container = {
      coredns = {
        enable = true;
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
            enable = true;
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
            enable = true;
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
        enable = true;
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
      vscode_server.enable = false;
    };
    network = {
      hostname = "enigma";
      wired = {
        enable = true;
        ip = "192.168.137.5/24";
        gateway = "192.168.137.1";
        mac = "2A:BE:78:89:51:A5";
        dns = [ "192.168.137.1" ];
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
      zabbix_agent = {
        enable = false;
        listenIP = "192.168.137.5";
        serverActive = "10.121.15.109:10051";
      };
    };
    user = {
      dave.enable = true;
      root.enable = false;
    };
  };

  #networking.nameservers = [ "192.168.137.1" ];

  #services.resolved = {
  #  enable = lib.mkForce false;
  #  dnssec = "false";
  #  domains = [ "~." ];
  #  fallbackDns = [ "192.168.137.1" ];
  #};
}
