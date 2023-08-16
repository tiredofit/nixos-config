{ config, pkgs, nur, ... } @ args:

{
  imports =
    [
      nur.nixosModules.nur # Use `config.nur.repos.<user>.<package-name>` in NixOS Module for packages from the NUR.
      ./hardware-configuration.nix
      ../../modules/nixos/default.nix
      ../../modules/nixos/services/btrbak.nix
      ../../modules/nixos/services/service-docker_container_manager.nix
      ../../modules/nixos/services/openssh.nix
      ../../modules/nixos/services/virtualization-docker.nix
    ];

  boot = {
    initrd = {
      checkJournalingFS = false;
    };
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
    ];
  };

  hostoptions = {
    impermanence = {
      enable = true;
      directories = [
        "/mnt/"
      ];
    };
  };

  fileSystems."/".options = [ "subvol=root" "compress=zstd" "noatime"  ];
  fileSystems."/boot".options = [ "defaults" "nosuid" "nodev" "noatime" "fmask=0022" "dmask=0022" "codepage=437" "iocharset=iso8859-1" "shortname=mixed" "errors=remount-ro" ] ;
  fileSystems."/home".options = [ "subvol=home/active" "compress=zstd" "noatime"  ];
  fileSystems."/home/.snapshots".options = [ "subvol=home/snapshots" "compress=zstd" "noatime"  ];
  fileSystems."/nix".options = [ "subvol=nix" "compress=zstd" "noatime"  ];
  fileSystems."/var/local".options = [ "subvol=var_local/active" "compress=zstd" "noatime"  ];
  fileSystems."/var/local/.snapshots".options = [ "subvol=var_local/snapshots" "compress=zstd" "noatime"  ];
  fileSystems."/var/log".options = [ "subvol=var_log" "compress=zstd" "noatime"  ];
  fileSystems."/var/log".neededForBoot = true;
  fileSystems."/mnt/media".options = [ "compress=zstd" "noatime" ] ;

  services.qemuGuest.enable = true;
  system.stateVersion = "23.11";

  networking = {
    hostName = "butcher";
    domain = "example.com";
    dhcpcd.enable = false;
    enableIPv6 = false;
    useNetworkd = true;
    firewall.enable = false;
    interfaces.enp6s18.ipv4.addresses = [{
      address = "192.168.137.5";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.137.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };
}
