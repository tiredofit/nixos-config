{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "vmw_pvscsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/740f60e3-d62c-48db-b74a-668912c0aef1";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/740f60e3-d62c-48db-b74a-668912c0aef1";
      fsType = "btrfs";
      options = [ "subvol=home/active" ];
    };

  fileSystems."/home/.snapshots" =
    { device = "/dev/disk/by-uuid/740f60e3-d62c-48db-b74a-668912c0aef1";
      fsType = "btrfs";
      options = [ "subvol=home/snapshots" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/740f60e3-d62c-48db-b74a-668912c0aef1";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/persist" =
    { device = "/dev/disk/by-uuid/740f60e3-d62c-48db-b74a-668912c0aef1";
      fsType = "btrfs";
      options = [ "subvol=persist/active" ];
    };

  fileSystems."/persist/.snapshots" =
    { device = "/dev/disk/by-uuid/740f60e3-d62c-48db-b74a-668912c0aef1";
      fsType = "btrfs";
      options = [ "subvol=persist/snapshots" ];
    };

  fileSystems."/var/lib/docker" =
    { device = "/dev/disk/by-uuid/740f60e3-d62c-48db-b74a-668912c0aef1";
      fsType = "btrfs";
      options = [ "subvol=var_lib_docker" ];
    };

  fileSystems."/var/local" =
    { device = "/dev/disk/by-uuid/740f60e3-d62c-48db-b74a-668912c0aef1";
      fsType = "btrfs";
      options = [ "subvol=var_local/active" ];
    };

  fileSystems."/var/local/.snapshots" =
    { device = "/dev/disk/by-uuid/740f60e3-d62c-48db-b74a-668912c0aef1";
      fsType = "btrfs";
      options = [ "subvol=var_local/snapshots" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/740f60e3-d62c-48db-b74a-668912c0aef1";
      fsType = "btrfs";
      options = [ "subvol=var_log" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/61FA-03B6";
      fsType = "vfat";
    };

  fileSystems."/mnt/media" =
    { device = "/dev/disk/by-uuid/9c3cfc7b-f660-44eb-9c60-d32342cdf174";
      fsType = "btrfs";
    };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
