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
      options = [ "subvol=root" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/4A74-66D0";
      fsType = "vfat";
    };
    "/home" = {
      device = "/dev/disk/by-uuid/fa060c23-d46e-4713-9a96-fb9513a2b551";
      fsType = "btrfs";
      options = [ "subvol=home/active" ];
    };
    "/home/.snapshots" = {
      device = "/dev/disk/by-uuid/fa060c23-d46e-4713-9a96-fb9513a2b551";
      fsType = "btrfs";
      options = [ "subvol=home/snapshots" ];
    };
    "/nix" = {
      device = "/dev/disk/by-uuid/fa060c23-d46e-4713-9a96-fb9513a2b551";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };
    "/persist" = {
      device = "/dev/disk/by-uuid/fa060c23-d46e-4713-9a96-fb9513a2b551";
      fsType = "btrfs";
      options = [ "subvol=persist/active" ];
    };
    "/persist/.snapshots" = {
      device = "/dev/disk/by-uuid/fa060c23-d46e-4713-9a96-fb9513a2b551";
      fsType = "btrfs";
      options = [ "subvol=persist/snapshots" ];
    };
    "/var/lib/docker" = {
      device = "/dev/disk/by-uuid/fa060c23-d46e-4713-9a96-fb9513a2b551";
      fsType = "btrfs";
      options = [ "subvol=var_lib_docker" ];
    };
    "/var/local" = {
      device = "/dev/disk/by-uuid/fa060c23-d46e-4713-9a96-fb9513a2b551";
      fsType = "btrfs";
      options = [ "subvol=var_local/active" ];
    };
    "/var/local/.snapshots" = {
      device = "/dev/disk/by-uuid/fa060c23-d46e-4713-9a96-fb9513a2b551";
      fsType = "btrfs";
      options = [ "subvol=var_local/snapshots" ];
    };
    "/var/log" = {
      device = "/dev/disk/by-uuid/fa060c23-d46e-4713-9a96-fb9513a2b551";
      fsType = "btrfs";
      options = [ "subvol=var_log" ];
    };
    "/mnt/media" = {
      device = "/dev/disk/by-uuid/9c3cfc7b-f660-44eb-9c60-d32342cdf174";
      fsType = "btrfs";
    };
  };
  #networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
