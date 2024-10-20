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
      luks = {
        devices = {
          "pool0_0" = {
            device = "/dev/disk/by-uuid/d1dd4e01-d147-41af-91b4-e736bf96bf78";
          };
        };
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/740f60e3-d62c-48db-b74a-668912c0aef1";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/61FA-03B6";
      fsType = "vfat";
    };
    "/home" = {
      device = "/dev/disk/by-uuid/740f60e3-d62c-48db-b74a-668912c0aef1";
      fsType = "btrfs";
      options = [ "subvol=home/active" ];
    };
    "/home/.snapshots" = {
      device = "/dev/disk/by-uuid/740f60e3-d62c-48db-b74a-668912c0aef1";
      fsType = "btrfs";
      options = [ "subvol=home/snapshots" ];
    };
    "/nix" = {
      device = "/dev/disk/by-uuid/740f60e3-d62c-48db-b74a-668912c0aef1";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };
    "/persist" = {
      device = "/dev/disk/by-uuid/740f60e3-d62c-48db-b74a-668912c0aef1";
      fsType = "btrfs";
      options = [ "subvol=persist/active" ];
    };
    "/persist/.snapshots" = {
      device = "/dev/disk/by-uuid/740f60e3-d62c-48db-b74a-668912c0aef1";
      fsType = "btrfs";
      options = [ "subvol=persist/snapshots" ];
    };
    "/var/lib/docker" = {
      device = "/dev/disk/by-uuid/740f60e3-d62c-48db-b74a-668912c0aef1";
      fsType = "btrfs";
      options = [ "subvol=var_lib_docker" ];
    };
    "/var/local" = {
      device = "/dev/disk/by-uuid/740f60e3-d62c-48db-b74a-668912c0aef1";
      fsType = "btrfs";
      options = [ "subvol=var_local/active" ];
    };
    "/var/local/.snapshots" = {
      device = "/dev/disk/by-uuid/740f60e3-d62c-48db-b74a-668912c0aef1";
      fsType = "btrfs";
      options = [ "subvol=var_local/snapshots" ];
    };
    "/var/log" = {
      device = "/dev/disk/by-uuid/740f60e3-d62c-48db-b74a-668912c0aef1";
      fsType = "btrfs";
      options = [ "subvol=var_log" ];
    };
    "/mnt/media" = {
      device = "/dev/disk/by-uuid/9c3cfc7b-f660-44eb-9c60-d32342cdf174";
      fsType = "btrfs";
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
