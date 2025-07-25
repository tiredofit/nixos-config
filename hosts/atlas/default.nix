{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

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
      postfix-relay = {
        enable = true;
        logship = false;
        monitor = false;
        ports = {
          smtp = {
            enable = true;
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
          submission = {
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
            enable = true;
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
            enable = true;
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
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "ampere";
      raid.enable = false;
    };
    network = {
      hostname = "atlas";
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
      coredns = {
        enable = true;
      };
      herald = {
        enable = true;
        general = {
          log_level = "verbose";
        };
        api = {
          enabled = true;
          listen = [ "zt*" ];
        };
        outputs = {
          api_aggregate = {
            type = "file";
            format = "zone";
            path = "/var/local/data/_system/zonefiles/%domain%.zone";
            default_ttl = 120;
            ns_records = [ "ns1.%domain%" ];
            soa = {
              primary_ns = "ns1.%domain%";
              admin_email = "admin@%domain%";
              serial = "auto";
              refresh = 3600;
              retry = 900;
              expire = 604800;
              minimum = 300;
            };
          };
        };
      };
      zabbix_agent = {
        enable = false;
        listenIP = "10.121.15.63";
        serverActive = "10.121.15.63:10051";
      };
      zeroplex = {
        enable = true;
        client = {
          port = config.host.network.vpn.zerotier.port;
        };
      };
    };
    user = {
      root.enable = true;
      dave.enable = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];

  services = {
    qemuGuest.enable = true;
  };
}
