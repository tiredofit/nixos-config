{ config, pkgs, nur, ... } @ args:

{
  imports =
    [
      nur.nixosModules.nur # Use `config.nur.repos.<user>.<package-name>` in NixOS Module for packages from the NUR.
      ./hardware-configuration.nix
      ../../modules/nixos/default.nix
      ../../modules/nixos/impermanence.nix
      ../../modules/nixos/services/btrbak.nix
      ../../modules/nixos/services/openssh.nix
      ../../modules/nixos/services/virtualization-docker.nix
    ];

  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = false;
      };
      grub = {
        device = "nodev";
        efiInstallAsRemovable = true;
        efiSupport = true;
        enable = true;
        enableCryptodisk = false;
        useOSProber = false;
      };
    };

    kernel.sysctl = {
        "vm.dirty_ratio" = 6;                                                   # sync disk when buffer reach 6% of memory
    };

    kernelPackages = pkgs.linuxPackages_latest;                                 # Latest kernel
    supportedFilesystems = [
      "btrfs"
      "fat" "vfat" "exfat" "ntfs" # Microsoft
      "cifs"                      # Windows Network Share
    ];
  };

  environment.persistence."/persist" = {
    hideMounts = true ;
    directories = [
      "/mnt/"
    ];
  };

  fileSystems."/".options = [ "subvol=root" "compress=zstd" "noatime"  ];
  fileSystems."/boot".options = [ "defaults" "nosuid" "nodev" "noatime" "fmask=0022" "dmask=0022" "codepage=437" "iocharset=iso8859-1" "shortname=mixed" "errors=remount-ro" ] ;
  fileSystems."/home".options = [ "subvol=home/active" "compress=zstd" "noatime"  ];
  fileSystems."/home/.snapshots".options = [ "subvol=home/snapshot" "compress=zstd" "noatime"  ];
  fileSystems."/nix".options = [ "subvol=nix" "compress=zstd" "noatime"  ];
  fileSystems."/var/local".options = [ "subvol=var_local/active" "compress=zstd" "noatime"  ];
  fileSystems."/var/local/.snapshots".options = [ "subvol=var_local/snapshot" "compress=zstd" "noatime"  ];
  fileSystems."/var/log".options = [ "subvol=var_log" "compress=zstd" "noatime"  ];
  fileSystems."/var/log".neededForBoot = true;
  fileSystems."/mnt/media".options = [ "defaults" "noatime" "codepage=437" "iocharset=iso8859-1" "errors=remount-ro" ] ;

  networking = {
    hostName = "butcher";
    networkmanager.enable = true;
  };

  system.stateVersion = "23.05";
}
