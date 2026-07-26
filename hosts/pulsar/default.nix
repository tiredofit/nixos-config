{ config, inputs, lib, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  # nixpkgs device-tree module defaults to
  # config.boot.kernelPackages.kernel.buildDTBs which doesn't exist
  # on linuxPackages_latest
  #hardware.deviceTree.enable = false;

  host = {
    container = {
      restic = {
        enable = false;
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
      fonts.enable = lib.mkForce true;
      graphics = {
        enable = true;
        backend = "wayland";
        displayManager.manager = "greetd";
        windowManager.manager = [ "hyprland" ];
        acceleration = true;
      };
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
      impermanence = {
        enable = true;
        persist.machine-id = true;
      };
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "intel";
      raid.enable = false;
    };
    network = {
      hostname = "pulsar";
      manager = "both";
      interfaces = {
        eth0 = {
          match = {
            mac = "00:d0:b4:01:51:a0";
          };
        };
        eth1 = {
          match = {
            mac = "00:d0:b4:01:51:a1";
          };
        };
        eth2 = {
          match = {
            mac = "00:d0:b4:01:51:a2";
          };
        };
        eth3 = {
          match = {
            mac = "00:d0:b4:01:51:a3";
          };
        };
        br-eth1 = { # Create VLAN sub-interfaces on br-eth1
          match = {
            name = "br-eth1";
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
        br-eth0 = {
          interfaces = [ "eth0" ];
          match = {
            name = "eth0";
          };
        };
        br-eth1 = {
          interfaces = [ "eth1" ];
          match = {
            name = "eth1";
          };
        };
        br-eth2 = {
          interfaces = [ "eth2" ];
          match = {
            name = "eth2";
          };
        };
        br-eth3 = {
          interfaces = [ "eth3" ];
          match = {
            name = "eth3";
          };
        };
        br-vlan23 = { # VLAN-specific bridges - Built on VLAN interfaces on br-eth1
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
        eth0 = {
          type = "unmanaged";
          match = {
            name = "br-eth0";
          };
        };
        eth1 = {
          type = "unmanaged";
          match = {
            name = "br-eth1";
          };
        };
        eth2 = {
          type = "unmanaged";
          match = {
            name = "br-eth2";
          };
        };
        eth3 = {
          type = "unmanaged";
          match = {
            name = "br-eth3";
          };
        };
        vlan23 = {
          type = "unmanaged";
          match = {
            name = "br-vlan23";
          };
        };
        vlan60 = {
          type = "unmanaged";
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
          type = "unmanaged";
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
    service = {
      lastlog.enable = true;
    };
    user = {
      root.enable = true;
      dave.enable = true;
      tttttt.enable = true;
    };
  };

  fonts.fontconfig.enable = lib.mkForce true;

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 5960 ];
      checkReversePath = "loose"; # libvirtd requirement
      #trustedInterfaces = [ "br-eth0" "br-eth1" "br-eth2" "br-eth3"];
    };
  };

  security.rtkit.enable = true;

  programs.hyprland.xwayland.enable = false;

  services.greetd = {
    settings = {
      default_session = {
        user = "tttttt";
        command = "uwsm start -e -D Hyprland hyprland";
      };
      initial_session = {
        user = "tttttt";
        command = "uwsm start -e -D Hyprland hyprland";
      };
      terminal.vt = 1;
    };
    restart = true;
  };

  environment = {
    systemPackages = with pkgs; [
      ghostty
      kitty
    ];
  };
}
