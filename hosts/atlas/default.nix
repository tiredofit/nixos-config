{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];


  host = {
    container = {
      authentik-outpost = {
        enable = true;
        image.update = true;
        instances = {
          atlas = {
            enable = true;
            proxy = {
              enable = true;
              ports = {
                http.enable = true;
                metrics.enable = true;
              };
            };
          };
        };
      };
      coredns = {
        enable = true;
        image.update = true;
        ports = {
          tcp = {
            enable = true;
            host = 530;
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
          udp = {
            enable = true;
            host = 530;
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
        };
      };
      openldap = {
        enable = true;
        image.update = true;
        containerName = builtins.replaceStrings ["." ] ["-"] ( "ldap." + config.host.network.domainname + "-app" );
        hostname = "ldap.${config.host.network.domainname}";
        certs = {
          volume = {
            source = "/var/local/data/_system/traefik-internal/certs/dump/${config.host.network.domainname}";
            target = "/certs/letsencrypt";
            readOnly = true;
          };
        };
        ports = {
          ldap = {
            enable = true;
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
        enable = false;
        image.update = true;
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
        enable = false;
        image.update = true;
      };
      socket-proxy = {
        enable = true;
        image.update = true;
      };
      traefik = {
        enable = true;
        image.update = true;
        instances = {
          traefik = {
            role = "public";
            enable = true;
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
            role = "internal";
            enable = true;
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
        };
      };
      unbound = {
        enable = true;
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
      swap.enable = false; #disko
      volatile = {
        enable = true;
      };
    };
    hardware = {
      cpu = "ampere";
      raid.enable = false;
    };
    network = {
      hostname = "atlas";
      interfaces = {
        eth0 = {
          match = {
            mac = "02:00:17:01:92:94";
          };
        };
      };
      networks = {
        eth0 = {
          type = "dynamic";
        };
      };
      vpn = {
        zerotier = {
          enable = true;
          networks = [
            "/var/run/secrets/zerotier/networks"
          ];
          port = 9994;
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
