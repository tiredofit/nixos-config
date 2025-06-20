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
      coredns = {
        enable = true;
      };
      herald = {
        enable = true;
        general = {
          log_level = "verbose";
        };
        inputs = {
          docker_pub = {
            type = "docker";
            api_url = "unix:///var/run/docker.sock";
            expose_containers = false;
            process_existing = true;
            record_remove_on_stop = true;
            filter = [
              {
                type = "label";
                conditions = [
                  {
                    key = "traefik.proxy.visibility";
                    value = "public";
                  }
                ];
              }
            ];
          };
          docker_int = {
            type = "docker";
            api_url = "unix:///var/run/docker.sock";
            expose_containers = false;
            process_existing = true;
            record_remove_on_stop = true;
            filter = [
              {
                type = "label";
                conditions = [
                  {
                    key = "traefik.proxy.visibility";
                    value = "internal";
                  }
                ];
              }
            ];
          };
        };
        domains = {
          domain01 = {
            profiles = {
              inputs = [ "docker_pub" ];
              outputs = [ "output01" ];
            };
          };
          domain02 = {
            profiles = {
              inputs = [ "docker_int" ];
              outputs = [ "output02"];
            };
          };
        };
      };
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
