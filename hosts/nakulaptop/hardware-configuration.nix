{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/2116df83-e8d7-4dfb-85ba-0c3d602c7d90";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/2116df83-e8d7-4dfb-85ba-0c3d602c7d90";
      fsType = "btrfs";
      options = [ "subvol=home/active" ];
    };

  fileSystems."/home/.snapshots" =
    { device = "/dev/disk/by-uuid/2116df83-e8d7-4dfb-85ba-0c3d602c7d90";
      fsType = "btrfs";
      options = [ "subvol=home/snapshots" ];
    };

  fileSystems."/mnt/data" =
    { device = "/dev/disk/by-uuid/412946e6-1d5b-44df-ba8e-06b60d3a0804";
      fsType = "btrfs";
      options = [ "subvol=__active" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/2116df83-e8d7-4dfb-85ba-0c3d602c7d90";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/persist" =
    { device = "/dev/disk/by-uuid/2116df83-e8d7-4dfb-85ba-0c3d602c7d90";
      fsType = "btrfs";
      options = [ "subvol=persist/active" ];
    };

  fileSystems."/persist/.snapshots" =
    { device = "/dev/disk/by-uuid/2116df83-e8d7-4dfb-85ba-0c3d602c7d90";
      fsType = "btrfs";
      options = [ "subvol=persist/snapshots" ];
    };

  fileSystems."/var/local" =
    { device = "/dev/disk/by-uuid/2116df83-e8d7-4dfb-85ba-0c3d602c7d90";
      fsType = "btrfs";
      options = [ "subvol=var_local/active" ];
    };

  fileSystems."/var/local/.snapshots" =
    { device = "/dev/disk/by-uuid/2116df83-e8d7-4dfb-85ba-0c3d602c7d90";
      fsType = "btrfs";
      options = [ "subvol=var_local/snapshots" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/2116df83-e8d7-4dfb-85ba-0c3d602c7d90";
      fsType = "btrfs";
      options = [ "subvol=var_log" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/1D4C-FB18";
      fsType = "vfat";
    };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
