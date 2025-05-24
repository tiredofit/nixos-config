{ config, inputs, lib, pkgs, ...}: {

  imports = [
    ./hardware-configuration.nix
    ../common
  ];

  host = {
    application = {
      openbao.enable = true;
    };
    container = {
      restic = {
        enable = true;
        logship = "false";
        monitor = "true";
      };
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
      hostname = "nomad";
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
