{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];


  fileSystems."/" =
    { device = "/dev/disk/by-uuid/7126e4d8-7e31-41c0-95c5-a70bc00bd758";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" "noatime" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/7126e4d8-7e31-41c0-95c5-a70bc00bd758";
      fsType = "btrfs";
      options = [ "subvol=home/active" "compress=zstd" "noatime" ];
    };

  fileSystems."/home/.snapshots" =
    { device = "/dev/disk/by-uuid/7126e4d8-7e31-41c0-95c5-a70bc00bd758";
      fsType = "btrfs";
      options = [ "subvol=home/snapshots" "compress=zstd" "noatime" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/7126e4d8-7e31-41c0-95c5-a70bc00bd758";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime" ];
    };

  fileSystems."/var/local" =
    { device = "/dev/disk/by-uuid/7126e4d8-7e31-41c0-95c5-a70bc00bd758";
      fsType = "btrfs";
      options = [ "subvol=var_local/active" "compress=zstd" "noatime" ];
    };

  fileSystems."/var/local/.snapshots" =
    { device = "/dev/disk/by-uuid/7126e4d8-7e31-41c0-95c5-a70bc00bd758";
      fsType = "btrfs";
      options = [ "subvol=var_local/snapshots" "compress=zstd" "noatime" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/7126e4d8-7e31-41c0-95c5-a70bc00bd758";
      fsType = "btrfs";
      options = [ "subvol=var_log" "compress=zstd" "noatime" "nodatacow" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/87BD-19EE";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  fileSystems."/var/lib/docker" =
    { device = "/dev/disk/by-uuid/7126e4d8-7e31-41c0-95c5-a70bc00bd758";
      fsType = "btrfs";
      options = [ "subvol=var_lib_docker" "compress=zstd" "noatime" ];
    };

  fileSystems."/persist" =
    { device = "/dev/disk/by-uuid/7126e4d8-7e31-41c0-95c5-a70bc00bd758";
      fsType = "btrfs";
      options = [ "subvol=persist/active" "compress=zstd" "noatime" ];
    };

  fileSystems."/persist/.snapshots" =
    { device = "/dev/disk/by-uuid/7126e4d8-7e31-41c0-95c5-a70bc00bd758";
      fsType = "btrfs";
      options = [ "subvol=persist/snapshots" "compress=zstd" "noatime" ];
    };

  #swapDevices = [
  #  {
  #   device = "/dev/disk/by-partlabel/swap";
  #  }
  #];



  #nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}