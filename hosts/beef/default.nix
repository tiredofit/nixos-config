{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.nur.nixosModules.nur
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
        monitor = "false";
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
    };
    feature = {
      gaming = {
        gamemode.enable = true;
        gamescope.enable = true;
        heroic.enable = true;
        steam = {
          enable = true;
          protonGE = true;
        };
      };
      graphics = {
        enable = true;
        backend = "x";
      };
      virtualization = {
        flatpak.enable = true;
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
    user = {
      dave.enable = true;
      root.enable = true;
    };
  };
}
