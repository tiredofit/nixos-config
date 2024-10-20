{ config, inputs, pkgs, ...}: {

  imports = [
    ./hardware-configuration.nix
    ./efi-btrfs-swap.nix
    ../common
  ];

  host = {
    feature = {
      appimage.enable = true;
      boot = {
        kernel = {
          parameters = [
            "video=HDMI-1:1920x1080@120"
          ];
        };
      };
      graphics = {
        enable = true;
        backend = "x";
      };
      virtualization = {
        flatpak.enable = true;
        waydroid.enable = true;
      };
    };
    filesystem = {
      encryption.enable = false;
      impermanence.enable = false;
      exfat.enable = true;
      ntfs.enable = true;
      swap = {
        partition = "disk/by-partlabel/swap";
      };
      tmp.tmpfs.enable = true;
    };
    hardware = {
      cpu = "amd";
      gpu = "amd";
      keyboard.enable = true;
      printing.enable = true;
      sound = {
        server = "pipewire";
      };
    };
    gaming = {
      steam = {
        enable = true;
        protonGe = true;
      };
      heroic = {
        enable = true;
        protonGe = true;
      };
      gamemode.enable = true;

    };
    network = {
      hostname = "hades";
    };
    role = "desktop";
    user = {
      alex.enable = true;
      josy.enable = true;
      root.enable = true;
    };
  };

  services.xserver = {
    enable = true;
    desktopManager = {
      cinnamon.enable = true;
      xterm.enable = false;
      session = [
        {
          name = "home-manager";
          start = ''
            ${pkgs.runtimeShell} $HOME/.hm-xsession &
            waitPID=$!
          '';
        }
        {
          name = "cinnamon";
          start = ''
            cinnamon
          '';
        }
      ];
    };
  };
}
