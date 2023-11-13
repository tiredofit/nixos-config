{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/045fce6b-58f9-4c51-a905-76067aea9f6d";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/045fce6b-58f9-4c51-a905-76067aea9f6d";
      fsType = "btrfs";
      options = [ "subvol=home/active" ];
    };

  fileSystems."/home/.snapshots" =
    { device = "/dev/disk/by-uuid/045fce6b-58f9-4c51-a905-76067aea9f6d";
      fsType = "btrfs";
      options = [ "subvol=home/snapshots" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/045fce6b-58f9-4c51-a905-76067aea9f6d";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/persist" =
    { device = "/dev/disk/by-uuid/045fce6b-58f9-4c51-a905-76067aea9f6d";
      fsType = "btrfs";
      options = [ "subvol=persist/active" ];
    };

  fileSystems."/persist/.snapshots" =
    { device = "/dev/disk/by-uuid/045fce6b-58f9-4c51-a905-76067aea9f6d";
      fsType = "btrfs";
      options = [ "subvol=persist/snapshots" ];
    };

  fileSystems."/var/local" =
    { device = "/dev/disk/by-uuid/045fce6b-58f9-4c51-a905-76067aea9f6d";
      fsType = "btrfs";
      options = [ "subvol=var_local/active" ];
    };

  fileSystems."/var/local/.snapshots" =
    { device = "/dev/disk/by-uuid/045fce6b-58f9-4c51-a905-76067aea9f6d";
      fsType = "btrfs";
      options = [ "subvol=var_local/snapshots" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/045fce6b-58f9-4c51-a905-76067aea9f6d";
      fsType = "btrfs";
      options = [ "subvol=var_log" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/AC30-9008";
      fsType = "vfat";
    };
}
