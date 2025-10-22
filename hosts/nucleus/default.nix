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
      #swap = {
      #  partition = "disk/by-partlabel/swap";
      #};
    };
    hardware = {
      cpu = "amd";
      raid.enable = true;
      wireless.enable = true;
    };
    network = {
      hostname = "nucleus";
      manager = "both";
      bridges = {
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
            name = "quad1";
          };
        };
      };
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
      };
      networks = {
        onboard = {
          type = "dynamic";
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

  networking.networkmanager.enable = true;
}
