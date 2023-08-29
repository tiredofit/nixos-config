{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices."pool0_0".device = "/dev/disk/by-uuid/8fbd9528-3a3b-4e69-97d4-7befe33e4305";
  boot.initrd.luks.devices."pool0_1".device = "/dev/disk/by-uuid/bf6d202c-c8ad-4415-9b7b-b70addad6d7b";
  boot.initrd.luks.devices."swap".device = "/dev/disk/by-uuid/bea444f7-fe48-4837-9db6-8c23d8b3ee26";

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

#  fileSystems."/mnt/data" =
#    { device = "/dev/disk/by-uuid/412946e6-1d5b-44df-ba8e-06b60d3a0804";
#      fsType = "btrfs";
#      options = [ "subvol=data" ];
#    };

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

  swapDevices =
    [ { device = "/dev/disk/by-uuid/0839e935-d57b-4384-9d48-f557d0250ec1"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
