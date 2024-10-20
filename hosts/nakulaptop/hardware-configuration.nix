{ config, lib, pkgs, modulesPath, ... }:

{
  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "uas"
        "sd_mod"
        "rtsx_usb_sdmmc"
      ];
      luks = {
        devices = {
          "pool0_0" = {
            device = "/dev/disk/by-uuid/d1dd4e01-d147-41af-91b4-e736bf96bf78";
          };
        };
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/D899-F17E";
      fsType = "vfat";
    };
    "/home" = {
      device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=home/active" ];
    };
    "/home/.snapshots" = {
      device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=home/snapshots" ];
    };
    "/mnt/data" = {
      device = "/dev/disk/by-uuid/412946e6-1d5b-44df-ba8e-06b60d3a0804";
      fsType = "btrfs";
      options = [ "subvol=__active" ];
    };
    "/nix" = {
      device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };
    "/persist" = {
      device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=persist/active" ];
    };
    "/persist/.snapshots" = {
      device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=persist/snapshots" ];
    };
    "/var/lib/docker" = {
      device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=var_lib_docker" ];
    };
    "/var/local" = {
      device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=var_local/active" ];
    };
    "/var/local/.snapshots" = {
      device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=var_local/snapshots" ];
    };
    "/var/log" = {
      device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=var_log" ];
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
