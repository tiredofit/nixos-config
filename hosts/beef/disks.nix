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
      ];
      luks = {
        devices = {
          "pool0_0" = {
            device = "/dev/disk/by-uuid/8fbd9528-3a3b-4e69-97d4-7befe33e4305";
          };
          "pool0_1" = {
            device = "/dev/disk/by-uuid/bf6d202c-c8ad-4415-9b7b-b70addad6d7b";
          };
          "swap" = {
            device = "/dev/disk/by-uuid/bea444f7-fe48-4837-9db6-8c23d8b3ee26";
          };
        };
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/2116df83-e8d7-4dfb-85ba-0c3d602c7d90";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" "noatime" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/1D4C-FB18";
      fsType = "vfat";
    };
    "/home" = {
      device = "/dev/disk/by-uuid/2116df83-e8d7-4dfb-85ba-0c3d602c7d90";
      fsType = "btrfs";
      options = [ "subvol=home/active" "compress=zstd" "noatime" ];
    };
    "/home/.snapshots" = {
      device = "/dev/disk/by-uuid/2116df83-e8d7-4dfb-85ba-0c3d602c7d90";
      fsType = "btrfs";
      options = [ "subvol=home/snapshots" "compress=zstd" "noatime" ];
    };
    "/mnt/data" = {
      device = "/dev/disk/by-uuid/412946e6-1d5b-44df-ba8e-06b60d3a0804";
      fsType = "btrfs";
      options = [ "subvol=__active" "compress=zstd" "noatime" "nofail" ];
    };
    "/nix" = {
      device = "/dev/disk/by-uuid/2116df83-e8d7-4dfb-85ba-0c3d602c7d90";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime" ];
    };
    "/persist" = {
      device = "/dev/disk/by-uuid/2116df83-e8d7-4dfb-85ba-0c3d602c7d90";
      fsType = "btrfs";
      options = [ "subvol=persist/active" "compress=zstd" "noatime" ];
    };
    "/persist/.snapshots" = {
      device = "/dev/disk/by-uuid/2116df83-e8d7-4dfb-85ba-0c3d602c7d90";
      fsType = "btrfs";
      options = [ "subvol=persist/snapshots" "compress=zstd" "noatime" ];
    };
    "/var/lib/docker" = {
      device = "/dev/disk/by-uuid/2116df83-e8d7-4dfb-85ba-0c3d602c7d90";
      fsType = "btrfs";
      options = [ "subvol=var_lib_docker" "compress=zstd" "noatime" ];
    };
    "/var/local" = {
      device = "/dev/disk/by-uuid/2116df83-e8d7-4dfb-85ba-0c3d602c7d90";
      fsType = "btrfs";
      options = [ "subvol=var_local/active" "compress=zstd" "noatime" ];
    };
    "/var/local/.snapshots" = {
      device = "/dev/disk/by-uuid/2116df83-e8d7-4dfb-85ba-0c3d602c7d90";
      fsType = "btrfs";
      options = [ "subvol=var_local/snapshots" "compress=zstd" "noatime" ];
    };
    "/var/log" = {
      device = "/dev/disk/by-uuid/2116df83-e8d7-4dfb-85ba-0c3d602c7d90";
      fsType = "btrfs";
      options = [ "subvol=var_log" "compress=zstd" "noatime" "nodatacow" ];
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
