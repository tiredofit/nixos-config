{ config, inputs, lib, pkgs, ...}: {

  imports = [
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
        enable = false;
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
      appimage.enable = true;
      development.crosscompilation.enable = true;
      gaming = {
        steam.enable = true;
      };
      graphics = {
        enable = true;
        backend = "wayland";
        displayManager.manager = "greetd";
        windowManager.manager = "hyprland";
      };
      virtualization = {
        flatpak.enable = true;
        waydroid.enable = false;
        virtd = {
          daemon.enable = true;
        };
        docker = {
          enable = true;
        };
      };
    };
    filesystem = {
      encryption.enable = true;
      impermanence.enable = true;
      exfat.enable = true;
      ntfs.enable = true;
      swap = {
        partition = "/dev/disk/by-partlabel/swap";
      };
      tmp.tmpfs.enable = true;
    };
    hardware = {
      cpu = "amd";
      gpu = "integrated-amd";
      sound = {
        server = "pipewire";
      };
      firmware.enable = true;
      gamecontroller.enable = true;
    };
    network = {
      firewall = {
        opensnitch.enable = false;
      };
      hostname = "nomad";
      manager = "networkmanager";
      resolved.enable = true;
      vpn = {
        zerotier = {
          enable = true;
          networks = [
            "/var/run/secrets/zerotier/networks"
          ];
          port = 9993;
        };
      };
      interfaces = {
        eth-onboard = {
          match = {
            mac = "c8:53:09:04:e3:5a";
          };
        };
        eth-dock = {
          match = {
            mac = "c8:53:09:04:e3:5b";
          };
        };
      };
      networks = {
        onboard = {
          match.name = "eth-onboard";
          type = "dynamic";
        };
        vlan23 = {
          type = "dynamic";
          match = {
            name = "eth-dock";
          };
        };
      };
    };
    role = "laptop";
    service = {
      herald = {
        enable = true;
        general = {
          log_level = "verbose";
          skip_domain_validation = true;
        };
      };
      zeroplex = {
        enable = true;
      };
    };
    user = {
      dave.enable = true;
      root.enable = true;
    };
  };
}
