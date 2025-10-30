{ config, inputs, lib, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    container = {
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
    };
    feature = {
      virtualization = {
        docker = {
          enable = true;
        };
        virtd = {
          daemon = {
            enable = true;
            makeImpermanent = false;
          };
        };
      };
    };
    filesystem = {
      encryption.enable = false;
      impermanence.enable = true;
    };
    hardware = {
      cpu = "amd";
      raid.enable = true;
      wireless.enable = true;
    };
    network = {
      hostname = "nucleus";
      manager = "both";
      interfaces = {
        onboard = {
          match = {
            mac = "d8:5e:d3:e7:65:b6";
          };
        };
        quad1 = {
          match = {
            mac = "00:E0:4C:69:8B:0C";
          };
        };
        quad2 = {
          match = {
            mac = "00:E0:4C:69:8B:0D";
          };
        };
        quad3 = {
          match = {
            mac = "00:E0:4C:69:8B:0E";
          };
        };
        quad4 = {
          match = {
            mac = "00:E0:4C:69:8B:0F";
          };
        };
        br-quad2 = { # Create VLAN sub-interfaces on br-quad2
          match = {
            name = "br-quad2";
          };
          vlans = [
            "vlan23"
            "vlan60"
            "vlan230"
            #"vlan468"
            "vlan1337"
          ];
        };
      };
      vlans = {
        vlan23 = {
          id = 23;
        };
        vlan60 = {
          id = 60;
        };
        vlan230 = {
          id = 230;
        };
        #vlan468 = {
        #  id = 468;
        #};
        vlan1337 = {
          id = 1337;
        };
      };
      bridges = {
        br-onboard = {
          interfaces = [ "onboard" ];
          match = {
            name = "onboard";
          };
        };
        br-quad1 = {
          interfaces = [ "quad1" ];
          match = {
            name = "quad1";
          };
        };
        br-quad2 = {
          interfaces = [ "quad2" ];
          match = {
            name = "quad2";
          };
        };
        br-quad3 = {
          interfaces = [ "quad3" ];
          match = {
            name = "quad3";
          };
        };
        br-quad4 = {
          interfaces = [ "quad4" ];
          match = {
            name = "quad4";
          };
        };
        br-vlan23 = { # VLAN-specific bridges - Built on VLAN interfaces on br-quad2
          interfaces = [ "vlan23" ];
        };
        br-vlan60 = {
          interfaces = [ "vlan60" ];
        };
        br-vlan230 = {
          interfaces = [ "vlan230" ];
        };
        #br-vlan468 = {
        #  interfaces = [ "vlan468" ];
        #};
        br-vlan1337 = {
          interfaces = [ "vlan1337" ];
        };
      };
      networks = {
        onboard = {
          type = "dynamic";
          match = {
            name = "br-onboard";
          };
        };
        quad1 = {
          type = "unmanaged";
          match = {
            name = "br-quad1";
          };
        };
        quad2 = {
          type = "unmanaged";
          match = {
            name = "br-quad2";
          };
        };
        quad3 = {
          type = "unmanaged";
          match = {
            name = "br-quad3";
          };
        };
        quad4 = {
          type = "unmanaged";
          match = {
            name = "br-quad4";
          };
        };
        vlan23 = {
          type = "dynamic";
          match = {
            name = "br-vlan23";
          };
        };
        vlan60 = {
          type = "dynamic";
          match = {
            name = "br-vlan60";
          };
        };
        vlan230 = {
          type = "dynamic";
          match = {
            name = "br-vlan230";
          };
        };
        #vlan468 = {
        #  type = "dynamic";
        #  match = {
        #    name = "br-vlan1337";
        #  };
        #};
        vlan1337 = {
          type = "dynamic";
          match = {
            name = "br-vlan1337";
          };
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
    user = {
      root.enable = lib.mkDefault true;
      dave.enable = lib.mkDefault true;
    };
  };

  networking.firewall.enable = false;
  networking.firewall = {
    trustedInterfaces = [ "br-quad1" "br-quad2" ];
  };
}
