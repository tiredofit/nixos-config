{ config, pkgs, nur, ... } @ args:

{
  imports =
    [
      nur.nixosModules.nur # Use `config.nur.repos.<user>.<package-name>` in NixOS Module for packages from the NUR.
      ./hardware-configuration.nix
      ../../modules/nixos/default.nix
      ../../modules/nixos/impermanence.nix
      ../../modules/nixos/gui/x.nix
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
        enable = true;
        device = "nodev";
        efiSupport = true;
        enableCryptodisk = false;
        useOSProber = false;
        efiInstallAsRemovable = true;
      };
    };

    kernel.sysctl = {
        "vm.dirty_ratio" = 6;                                                   # sync disk when buffer reach 6% of memory
    };

    kernelPackages = pkgs.linuxPackages_latest;                                 # Latest kernel

    kernelParams = [ "resume_offset=4503599627370495" ];                        # Hibernation 'btrfs inspect-internal map-swapfile -r /mnt/swap/swapfile'
    resumeDevice = "/dev/disk/by-uuid/558e1b77-4ddc-4080-82e7-ecfb4045a79d" ;   # Hibernation 'blkid | grep '/dev/mapper/pool0_0' | awk '{print $2}' | cut -d '"' -f 2)'

    plymouth.enable = true ;

    supportedFilesystems = [
      "btrfs"
      "fat" "vfat" "exfat" "ntfs" # Microsoft
      "cifs"                      # Windows Network Share
    ];
  };

  fileSystems."/".options = [ "subvol=root" "compress=zstd" "noatime"  ];
  fileSystems."/home".options = [ "subvol=home/active" "compress=zstd" "noatime"  ];
  fileSystems."/home/.snapshots".options = [ "subvol=home/snapshot" "compress=zstd" "noatime"  ];
  fileSystems."/nix".options = [ "subvol=nix" "compress=zstd" "noatime"  ];
  fileSystems."/var/local".options = [ "subvol=var_local/active" "compress=zstd" "noatime"  ];
  fileSystems."/var/local/.snapshots".options = [ "subvol=var_local/snapshot" "compress=zstd" "noatime"  ];
  fileSystems."/var/log".options = [ "subvol=var_log" "compress=zstd" "noatime"  ];
  fileSystems."/var/log".neededForBoot = true;

  networking = {
    hostName = "soy";
    networkmanager.enable = true;
  };

  services.qemuGuest.enable = true
  system.stateVersion = "23.05";
}
