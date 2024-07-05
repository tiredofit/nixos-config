{ config, inputs, pkgs, ...}: {

  imports = [
    ./hardware-configuration.nix
    ../common
  ];

  boot = {
    kernelParams = [
      "quiet"
      "video=DP-3:2560x1440@120"
      "video=DP-2:2560x1440@120"
      "video=HDMI-1:2560x1440@120"
      "amdgpu.sg_display=0"
    ];
  };

  host = {
    container = {
      restic = {
        enable = true;
        logship = "false";
        monitor = "true";
      };
      socket-proxy = {
        enable = true;
        logship = "false";
        monitor = "false";
      };
      tinc = {
        enable = true;
        logship = "false";
        monitor = "false";
      };
      traefik = {
        enable = true;
        logship = "false";
        monitor = "false";
      };
      cloudflare-companion = {
        enable = true;
        logship = "false";
        monitor = "false";
      };
    };
    feature = {
      appimage.enable = true;
      gaming = {
        gamemode.enable = false;
        gamescope.enable = false;
        heroic.enable = false;
        steam = {
          enable = false;
          protonGE = false;
        };
      };
      graphics = {
        enable = true;
        backend = "wayland";
        displayManager.manager = "sddm";
        windowManager.manager = "hyprland";
      };
      virtualization = {
        flatpak.enable = true;
        waydroid.enable = true;
      };
    };
    filesystem = {
      bcachefs.enable = true;
      encryption.enable = true;
      exfat.enable = true;
      ntfs.enable = true;
      swap = {
        partition = "disk/by-uuid/0839e935-d57b-4384-9d48-f557d0250ec1";
      };
      tmp.tmpfs.enable = true;
    };
    hardware = {
      cpu = "amd";
      gpu = "integrated-amd";
      keyboard.enable = true;
      raid.enable = true;
      sound = {
        server = "pipewire";
      };
    };
    network = {
      hostname = "beef";
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
    role = "desktop";
    service = {
      zabbix_agent = {
        enable = true;
        listenIP = "192.168.23.23";
        serverActive = "10.121.15.60:10051";
      };
    };
    user = {
      dave.enable = true;
      root.enable = true;
    };
  };
}
