{ config, inputs, lib, pkgs, ...}: {

  imports = [
    ./disks.nix
    ../common
  ];

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
        windowManager.manager = [ "cosmic" "hyprland" "niri" ];
      };
      nix-ld.enable = true;
      virtualization = {
        flatpak.enable = true;
        waydroid.enable = false;
        virtd = {
          daemon.enable = false;
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
      keyboard = {
        via.enable = true;
        remap = {
          enable = true;
          key = {
            capslock = "escape";
            escape = "noop";
          };
        };
      };
      gamecontroller.enable = true;
      wireless.enable = true;
    };
    network = {
      firewall = {
        opensnitch.enable = false;
      };
      hostname = "nomad";
      manager = "networkmanager";
      resolved.enable = true;
      vpn = {
        openvpn.enable = true;
        zerotier = {
          enable = true;
          configureClientFirewall = false;
          configureExitFirewall = false;
          exitNode = false;
          networks = [
            "/var/run/secrets/zerotier/networks"
          ];
          port = 9993;
          cliUsers = [
            "dave"
          ];
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

  # nixpkgs device-tree module defaults to
  # config.boot.kernelPackages.kernel.buildDTBs which doesn't exist
  # on linuxPackages_latest
  hardware.deviceTree.enable = false;
  system.boot.loader.kernelFile = "bzImage";

  ## KDE Connect
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  networking.firewall.extraCommands = ''
    iptables -I INPUT -p tcp --dport 1714:1760 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -I INPUT -p udp --dport 1714:1760 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
  '';

  programs.kdeconnect = {
    enable = true;
    package = pkgs.kdePackages.kdeconnect-kde;
  };

  environment.systemPackages = with pkgs; [ kdePackages.kdeconnect-kde ];

  ## ESPHome
  services.esphome = {
    enable = true;
    address = "0.0.0.0";
    port = 6052;
    openFirewall = true;

    allowedDevices = [
      "/dev/ttyUSB0"
      "/dev/ttyUSB1"
      "/dev/ttyACM0"
      "/dev/ttyACM1"
    ];
  };

  systemd.services.esphome = {
    environment = {
      PLATFORMIO_CORE_DIR = lib.mkForce "/var/lib/esphome/.platformio";
    };
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "esphome";
      Group = "esphome";
      WorkingDirectory = lib.mkForce "/var/lib/esphome";
      ReadWritePaths = [ "/var/lib/esphome" ];
    };
  };

  users.users.esphome = {
    isSystemUser = true;
    group = "esphome";
    extraGroups = [ "dialout" "wheel" ];
  };

#services.keyd = {
#  enable = true;
#  keyboards = {
#    default = {
#      ids = [ "*" ];
#      settings = {
#        main = {
#          capslock = "esc";
#          esc = "capslock";
#        };
#      };
#    };
#  };
#};
}
