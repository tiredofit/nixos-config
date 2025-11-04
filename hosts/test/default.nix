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
    };
    feature = {
      virtualization = {
        docker = {
         enable = true;
        };
      };
    };
    filesystem = {
      encryption.enable = false;                 # This line can be removed if not needed as it is already default set by the role template
      impermanence.enable = true;                # This line can be removed if not needed as it is already default set by the role template
      #swap = {
      #  partition = "disk/by-partlabel/swap";
      #};
    };
    hardware = {
      cpu = "vm-amd";
      raid.enable = false;
    };
    service = {
      docker_container_manager = {
        enable = lib.mkForce true;  # Enable start/stop containers on bootup/shutdown
      };
    };
    network = {
      firewall.fail2ban.enable = false;
      hostname = "test";
      interfaces = {
        eth60 = {
          match = {
            mac = "52:54:00:44:71:80";
          };
        };
        eth1337 = {
           match = {
            mac = "52:54:00:8a:c9:b3";
          };
        };
      };
      bridges = {
        br-vlan60 = {
          interfaces = [ "eth60" ];
        };
        br-vlan1337 = {
          interfaces = [ "eth1337" ];
        };
      };
      networks = {
        vlan60 = {
          type = "dynamic";
          match = {
            name = "br-vlan60";
          };
        };
        vlan1337 = {
          type = "dynamic";
          match = {
            name = "br-vlan1337";
          };
        };
      };
    };
    role = "server";
    user = {
      root.enable = lib.mkDefault true;
      dave.enable = lib.mkDefault true;
    };
  };

  networking.firewall.enable = false;
}
