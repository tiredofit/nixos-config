{ config, inputs, pkgs, ...}: {

  imports = [
    ./disks.nix
    ../common
  ];

  boot.blacklistedKernelModules = [
    "snd_hda_codec_hdmi"
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
      appimage.enable = true;
      boot = {
        kernel = {
          modulesBlacklist = [
            "snd_hda_codec_hdmi"
          ];
          parameters = [
            "video=DP-3:2560x1440@120"
            "video=DP-2:2560x1440@120"
            "video=HDMI-1:2560x1440@120"
          ];
        };
      };
      development.crosscompilation.enable = true;
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
      firewall = {
        opensnitch.enable = false;
      };
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
    user = {
      dave.enable = true;
      root.enable = true;
    };
  };
}
