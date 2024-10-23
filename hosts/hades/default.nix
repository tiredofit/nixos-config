{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
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
      gaming = {
        steam = {
          enable = true;
          protonGE = true;
        };
        heroic = {
          enable = true;
          protonGE = true;
        };
        gamemode.enable = true;
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
      raid.enable = false;
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

  users.mutableUsers = true;

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
