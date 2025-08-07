{ config, lib, pkgs, ... }:

{
  boot = {
    initrd = {
      availableKernelModules = [
        "uhci_hcd"
        "ehci_pci"
        "ahci"
        "vmw_pvscsi"
        "sd_mod"
        "sr_mod"
      ];
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/fa060c23-d46e-4713-9a96-fb9513a2b551";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" "noatime" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/4A74-66D0";
      fsType = "vfat";
    };
    "/home" = {
      device = "/dev/disk/by-uuid/fa060c23-d46e-4713-9a96-fb9513a2b551";
      fsType = "btrfs";
      options = [ "subvol=home/active" "compress=zstd" "noatime" ];
    };
    "/home/.snapshots" = {
      device = "/dev/disk/by-uuid/fa060c23-d46e-4713-9a96-fb9513a2b551";
      fsType = "btrfs";
      options = [ "subvol=home/snapshots" "compress=zstd" "noatime" ];
    };
    "/nix" = {
      device = "/dev/disk/by-uuid/fa060c23-d46e-4713-9a96-fb9513a2b551";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };
    "/persist" = {
      device = "/dev/disk/by-uuid/fa060c23-d46e-4713-9a96-fb9513a2b551";
      fsType = "btrfs";
      options = [ "subvol=persist/active" "compress=zstd" "noatime" ];
    };
    "/persist/.snapshots" = {
      device = "/dev/disk/by-uuid/fa060c23-d46e-4713-9a96-fb9513a2b551";
      fsType = "btrfs";
      options = [ "subvol=persist/snapshots" "compress=zstd" "noatime" ];
    };
    "/var/lib/docker" = {
      device = "/dev/disk/by-uuid/fa060c23-d46e-4713-9a96-fb9513a2b551";
      fsType = "btrfs";
      options = [ "subvol=var_lib_docker" "compress=zstd" "noatime" ];
    };
    "/var/local" = {
      device = "/dev/disk/by-uuid/fa060c23-d46e-4713-9a96-fb9513a2b551";
      fsType = "btrfs";
      options = [ "subvol=var_local/active" "compress=zstd" "noatime" ];
    };
    "/var/local/.snapshots" = {
      device = "/dev/disk/by-uuid/fa060c23-d46e-4713-9a96-fb9513a2b551";
      fsType = "btrfs";
      options = [ "subvol=var_local/snapshots" "compress=zstd" "noatime" ];
    };
    "/var/log" = {
      device = "/dev/disk/by-uuid/fa060c23-d46e-4713-9a96-fb9513a2b551";
      fsType = "btrfs";
      options = [ "subvol=var_log" "compress=zstd" "noatime" "nodatacow" ];
    };
    "/mnt/media" = {
      device = "/dev/disk/by-uuid/9c3cfc7b-f660-44eb-9c60-d32342cdf174";
      fsType = "btrfs";
      options = [ "compress=zstd" "noatime" ];
    };
  };
}
