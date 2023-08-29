{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sr_mod" "virtio_blk" ];
  boot.initrd.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [ "resume_offset=4503599627370495" ];
  boot.resumeDevice = "/dev/disk/by-uuid/558e1b77-4ddc-4080-82e7-ecfb4045a79d" ;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/558e1b77-4ddc-4080-82e7-ecfb4045a79d";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  boot.initrd.luks.devices."pool0_0".device = "/dev/disk/by-uuid/4ab91d3d-a9e2-498d-a172-0e4223591ebf";

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/558e1b77-4ddc-4080-82e7-ecfb4045a79d";
      fsType = "btrfs";
      options = [ "subvol=home/active" ];
    };

  fileSystems."/home/.snapshots" =
    { device = "/dev/disk/by-uuid/558e1b77-4ddc-4080-82e7-ecfb4045a79d";
      fsType = "btrfs";
      options = [ "subvol=home/snapshots" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/558e1b77-4ddc-4080-82e7-ecfb4045a79d";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/persist" =
    { device = "/dev/disk/by-uuid/558e1b77-4ddc-4080-82e7-ecfb4045a79d";
      fsType = "btrfs";
      options = [ "subvol=persist/active" ];
      neededForBoot = true;
    };

  fileSystems."/persist/.snapshots" =
    { device = "/dev/disk/by-uuid/558e1b77-4ddc-4080-82e7-ecfb4045a79d";
      fsType = "btrfs";
      options = [ "subvol=persist/snapshots" ];
      neededForBoot = true;
    };

  fileSystems."/swap" =
    { device = "/dev/disk/by-uuid/558e1b77-4ddc-4080-82e7-ecfb4045a79d";
      fsType = "btrfs";
      options = [ "subvol=swap" ];
    };

  fileSystems."/var/local" =
    { device = "/dev/disk/by-uuid/558e1b77-4ddc-4080-82e7-ecfb4045a79d";
      fsType = "btrfs";
      options = [ "subvol=var_local/active" ];
    };

  fileSystems."/var/local/.snapshots" =
    { device = "/dev/disk/by-uuid/558e1b77-4ddc-4080-82e7-ecfb4045a79d";
      fsType = "btrfs";
      options = [ "subvol=var_local/snapshots" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/558e1b77-4ddc-4080-82e7-ecfb4045a79d";
      fsType = "btrfs";
      options = [ "subvol=var_log" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/CAE8-394C";
      fsType = "vfat";
    };

  swapDevices = [{
    device = "/swap/swapfile";
    size = (1024 * 4) + (1024 * 2); # RAM size + 2 GB
  }];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
