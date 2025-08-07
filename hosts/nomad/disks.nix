{ config, lib, pkgs, modulesPath, ... }:

{
  boot = {
    initrd = {
      luks = {
        devices = {
          "pool0_0" = {
            device = "/dev/disk/by-uuid/0706bfbf-e123-47c3-b987-6be82f5b6c50";
          };
        };
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/98114b5f-d539-4c2f-b7d8-3856df96c11e";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" "noatime" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/270C-5543";
      fsType = "vfat";
    };
    "/home" = {
      device = "/dev/disk/by-uuid/98114b5f-d539-4c2f-b7d8-3856df96c11e";
      fsType = "btrfs";
      options = [ "subvol=home/active" "compress=zstd" "noatime" ];
    };
    "/home/.snapshots" = {
      device = "/dev/disk/by-uuid/98114b5f-d539-4c2f-b7d8-3856df96c11e";
      fsType = "btrfs";
      options = [ "subvol=home/snapshots" "compress=zstd" "noatime" ];
    };
    "/nix" = {
      device = "/dev/disk/by-uuid/98114b5f-d539-4c2f-b7d8-3856df96c11e";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime" ];
    };
    "/persist" = {
      device = "/dev/disk/by-uuid/98114b5f-d539-4c2f-b7d8-3856df96c11e";
      fsType = "btrfs";
      options = [ "subvol=persist/active" "compress=zstd" "noatime" ];
    };
    "/persist/.snapshots" = {
      device = "/dev/disk/by-uuid/98114b5f-d539-4c2f-b7d8-3856df96c11e";
      fsType = "btrfs";
      options = [ "subvol=persist/snapshots" "compress=zstd" "noatime" ];
    };
    "/var/lib/docker" = {
      device = "/dev/disk/by-uuid/98114b5f-d539-4c2f-b7d8-3856df96c11e";
      fsType = "btrfs";
      options = [ "subvol=var_lib_docker" "compress=zstd" "noatime" ];
    };
    "/var/local" = {
      device = "/dev/disk/by-uuid/98114b5f-d539-4c2f-b7d8-3856df96c11e";
      fsType = "btrfs";
      options = [ "subvol=var_local/active" "compress=zstd" "noatime" ];
    };
    "/var/local/.snapshots" = {
      device = "/dev/disk/by-uuid/98114b5f-d539-4c2f-b7d8-3856df96c11e";
      fsType = "btrfs";
      options = [ "subvol=var_local/snapshots" "compress=zstd" "noatime" ];
    };
    "/var/log" = {
      device = "/dev/disk/by-uuid/98114b5f-d539-4c2f-b7d8-3856df96c11e";
      fsType = "btrfs";
      options = [ "subvol=var_log" "compress=zstd" "noatime" "nodatacow" ];
    };
  };
}
