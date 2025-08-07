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
      options = [ "subvol=root" "compress=zstd" "noatime" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/D899-F17E";
      fsType = "vfat";
    };
    "/home" = {
      device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=home/active" "compress=zstd" "noatime" ];
    };
    "/home/.snapshots" = {
      device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=home/snapshots" "compress=zstd" "noatime" ];
    };
    "/nix" = {
      device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime" ];
    };
    "/persist" = {
      device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=persist/active" "compress=zstd" "noatime" ];
    };
    "/persist/.snapshots" = {
      device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=persist/snapshots" "compress=zstd" "noatime" ];
    };
    "/var/lib/docker" = {
      device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=var_lib_docker" "compress=zstd" "noatime" ];
    };
    "/var/local" = {
      device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=var_local/active" "compress=zstd" "noatime" ];
    };
    "/var/local/.snapshots" = {
      device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=var_local/snapshots" "compress=zstd" "noatime" ];
    };
    "/var/log" = {
      device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=var_log" "compress=zstd" "noatime" "nodatacow" ];
    };
  };
}
