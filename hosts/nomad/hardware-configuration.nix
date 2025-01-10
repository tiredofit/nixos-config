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
      options = [ "subvol=root" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/270C-5543";
      fsType = "vfat";
    };
    "/home" = {
      device = "/dev/disk/by-uuid/98114b5f-d539-4c2f-b7d8-3856df96c11e";
      fsType = "btrfs";
      options = [ "subvol=home/active" ];
    };
    "/home/.snapshots" = {
      device = "/dev/disk/by-uuid/98114b5f-d539-4c2f-b7d8-3856df96c11e";
      fsType = "btrfs";
      options = [ "subvol=home/snapshots" ];
    };
    "/nix" = {
      device = "/dev/disk/by-uuid/98114b5f-d539-4c2f-b7d8-3856df96c11e";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };
    "/persist" = {
      device = "/dev/disk/by-uuid/98114b5f-d539-4c2f-b7d8-3856df96c11e";
      fsType = "btrfs";
      options = [ "subvol=persist/active" ];
    };
    "/persist/.snapshots" = {
      device = "/dev/disk/by-uuid/98114b5f-d539-4c2f-b7d8-3856df96c11e";
      fsType = "btrfs";
      options = [ "subvol=persist/snapshots" ];
    };
    "/var/lib/docker" = {
      device = "/dev/disk/by-uuid/98114b5f-d539-4c2f-b7d8-3856df96c11e";
      fsType = "btrfs";
      options = [ "subvol=var_lib_docker" ];
    };
    "/var/local" = {
      device = "/dev/disk/by-uuid/98114b5f-d539-4c2f-b7d8-3856df96c11e";
      fsType = "btrfs";
      options = [ "subvol=var_local/active" ];
    };
    "/var/local/.snapshots" = {
      device = "/dev/disk/by-uuid/98114b5f-d539-4c2f-b7d8-3856df96c11e";
      fsType = "btrfs";
      options = [ "subvol=var_local/snapshots" ];
    };
    "/var/log" = {
      device = "/dev/disk/by-uuid/98114b5f-d539-4c2f-b7d8-3856df96c11e";
      fsType = "btrfs";
      options = [ "subvol=var_log" ];
    };
  };
}
