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
      impermanence.enable = true;               # This line can be removed if not needed as it is already default set by the role template
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
        enp0 = {
          match = {
            mac = "52:54:00:09:c4:07";
          };
        };
        veth0 = { # Connected to nucleus br-quad2
          match = {
            mac = "52:54:00:b9:02:e2";
          };
        };
        vveth = { # Connected to nucleus br-vlan60
          match = {
            mac = "52:54:00:c0:53:f4";
          };
        };
        br-veth0 = { # Create VLAN sub-interfaces on br-veth0 (receives tagged traffic from Nucleus)
          match = {
            name = "br-veth0";
          };
          vlans = [
            "vlan60"
            "vlan230"
            "vlan1337"
          ];
        };
      };
      vlans = {
        vlan60 = {
          id = 60;
        };
        vlan230 = {
          id = 230;
        };
        vlan1337 = {
          id = 1337;
        };
      };
      bridges = {
        br-veth0 = { # Bridge veth0 to receive all tagged VLAN traffic from Nucleus br-quad2
          interfaces = [ "veth0" ];
        };
        br-vlan60 = { # Then create VLAN-specific bridges for containers/VMs
          interfaces = [ "vlan60" ];
        };
        br-vlan230 = {
          interfaces = [ "vlan230" ];
        };
        br-vlan1337 = {
          interfaces = [ "vlan1337" ];
        };
      };
      networks = {
        enp0 = {
          type = "dynamic";
        };
        veth0-bridge = { # veth0 is bridged (br-veth0) - no IP on veth0 itself, br-veth0 is unmanaged - just passes VLAN traffic through
          type = "unmanaged";
          match = {
            name = "br-veth0";
          };
        };
        vveth = { # Direct access to VLAN 60 via vveth
          type = "dynamic";
        };
        vlan60 = {
          type = "dynamic"; # Host gets IP on VLAN 60
          match = {
            name = "br-vlan60";
          };
        };
        vlan230 = {
          type = "dynamic";  # TEST host gets IP on VLAN 230
          match = {
            name = "br-vlan230";
          };
        };
        vlan1337 = {
          type = "dynamic";  # TEST host gets IP on VLAN 1337
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
