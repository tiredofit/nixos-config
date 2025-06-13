{ config, inputs, lib, pkgs, ...}: {

  imports = [
    ./hardware-configuration.nix
    ../common
  ];

  host = {
    container = {
      restic = {
        enable = true;
        logship = "false";
        monitor = "false";
      };
      #traefik = {
      #  enable = true;
      #  logship = "false";
      #  monitor = "false";
      #};
      #traefik-internal = {
      #  enable = true;
      #  logship = "false";
      #  monitor = "false";
      #  networkBinding = {
      #    enable = true;
      #    method = "zerotier";
      #    zerotierNetwork = "d06d0877e069285c";  # or "tiredofit"
      #    ports = [ "80:80" "443:443" ];
      #    beforeServices = [
      #      "docker-traefik.service"           # Start before the regular traefik
      #      #"docker-nginx.service"             # Start before nginx if you have it
      #      #"docker-caddy.service"             # Start before caddy if you have it
      #      # Add any other containers that use the same ports
      #    ];
      #  };
      #};
    };

    feature = {
      appimage.enable = true;
      development.crosscompilation.enable = true;
      graphics = {
        enable = true;
        backend = "wayland";
        displayManager.manager = "greetd";
        windowManager.manager = "hyprland";
      };
      virtualization = {
        flatpak.enable = true;
        waydroid.enable = true;
        virtd = {
          daemon.enable = true;
        };
      };
    };
    filesystem = {
      encryption.enable = true;             # This line can be removed if not needed as it is already default set by the role template
      impermanence.enable = true;           # This line can be removed if not needed as it is already default set by the role template
      exfat.enable = true;
      ntfs.enable = true;
      swap = {
        partition = "disk/by-uuid/323a1f63-524e-4891-a428-fb42cf6c169a";
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
    };
    network = {
      firewall = {
        opensnitch.enable = true;
      };
      hostname = "nomad";
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
    role = "laptop";
    service = {
      dns-companion = {
        enable = true;
        general = {
          log_level = "debug";
        };
        polls = {
          docker = {
            type = "docker";
          };
        };
      };
      coredns = {
        enable = true;
      };
      zt-dns-companion = {
        enable = true;
      };
    };
    user = {
      dave.enable = true;
      root.enable = true;
    };
  };
}