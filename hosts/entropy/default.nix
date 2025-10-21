{ config, inputs, lib, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    container = {
      clamav = {
        enable = false;
        logship = false;
        monitor = false;
      };
      coredns = {
        enable = true;
        logship = false;
        monitor = false;
      };
      openldap = {
        enable = false;
        logship = false;
        monitor = false;
        ports = {
          ldap = {
            enable = false;
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
          ldaps = {
            enable = true;
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
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
          https = {
            enable = true;
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
          http3 = {
            enable = true;
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
        };
      };
      unbound = {
        enable = true;
        monitor = false;
        logship = false;
        secrets = {
          enable = true;
        };
        ports = {
          dns = {
            enable = true;
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
          dns_tcp = {
            enable = true;
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
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
        };
      };
    };
    feature = {
    };
    filesystem = {
      encryption.enable = true;
      impermanence.enable = true;
      swap.enable = false; # disko is handling this
    };
    hardware = {
      cpu = "amd";
      raid.enable = true;
    };
    network = {
      hostname = "entropy";
      interfaces = {
        enp3s0f0 = {
          match = {
            mac = "34:5a:60:00:a8:68";
          };
        };
      };
      bridges = {
        br0 = {
          name = "br0";
          interfaces = [ "enp3s0f0" ];
          match = {
           name = "enp3s0f0";
          };
          linkLocalAddressing = false;
          stp = false;
        };
      };
      networks = {
        br0 = {
          match = {
            name = "br0";
          };
          type = "static";
          ip = "148.113.219.154/32";
          gateway = "100.64.0.1";
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
        general = {
          log_level = "verbose";
        };
      };
      vscode_server.enable = true;
      zeroplex = {
        enable = true;
        #mode = "resolved";
      };
    };
    user = {
      root.enable = true;
      dave.enable = true;
    };
  };
}
