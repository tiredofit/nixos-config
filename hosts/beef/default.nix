{ config, pkgs, nur, ... } @ args:

{
  imports =
    [
      nur.nixosModules.nur # Use `config.nur.repos.<user>.<package-name>` in NixOS Module for packages from the NUR.
      ./hardware-configuration.nix
      ../../modules/nixos/bluetooth.nix
      ../../modules/nixos/default.nix
      ../../modules/nixos/impermanence.nix
      ../../modules/nixos/plymouth.nix
      ../../modules/nixos/printing.nix
      ../../modules/nixos/raid.nix
      ../../modules/nixos/gui/x.nix
      ../../modules/nixos/services/btrbak.nix
      ../../modules/nixos/services/opensnitch.nix
      ../../modules/nixos/services/openssh.nix
      ../../modules/nixos/services/tailscale.nix
      ../../modules/nixos/services/virtualization-docker.nix
      ../../modules/nixos/services/virtualization-virt-manager.nix
      ../../modules/nixos/services/vscode-server.nix
    ];

  boot = {
    binfmt = {
      emulatedSystems = [ "aarch64-linux" ]; # Allow to build aarch64 binaries
    };
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

    initrd.luks.devices = {
      "pool0_0" = {
         allowDiscards = true;
         bypassWorkqueues = true;
      };
      "pool0_1" = {
         allowDiscards = true;
         bypassWorkqueues = true;
      };
    };

    kernel.sysctl = {
      "vm.dirty_ratio" = 6;   # sync disk when buffer reach 6% of memory
    };

    kernelPackages = pkgs.linuxPackages_latest;  # Latest kernel
    kernelParams = [ "quiet" "amd_pstate=active" ];

    supportedFilesystems = [
      "btrfs"
      "vfat"
    ];
  };

  fileSystems."/".options = [ "subvol=root" "compress=zstd" "noatime"  ];
  fileSystems."/home".options = [ "subvol=home/active" "compress=zstd" "noatime"  ];
  fileSystems."/home".neededForBoot = true;
  fileSystems."/home/.snapshots".options = [ "subvol=home/snapshot" "compress=zstd" "noatime"  ];
  fileSystems."/nix".options = [ "subvol=nix" "compress=zstd" "noatime"  ];
  fileSystems."/var/local".options = [ "subvol=var_local/active" "compress=zstd" "noatime"  ];
  fileSystems."/var/local/.snapshots".options = [ "subvol=var_local/snapshot" "compress=zstd" "noatime"  ];
  fileSystems."/var/log".options = [ "subvol=var_log" "compress=zstd" "noatime"  ];
  fileSystems."/var/log".neededForBoot = true;

  networking = {
    hostName = "beef";
    networkmanager.enable = true;
  };

  nixpkgs.config.allowUnfree = true;                                            # allow unfree packages
  services.xserver.videoDrivers = [ "nvidia" ];                                 # nvidia 960
  hardware.opengl.enable = true;                                                # enable opengl
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;   # stick with the stable track
  hardware.nvidia.modesetting.enable = true;                                    # enable kms

  powerManagement = {
    enable = true ;
  };

  services.printing.drivers = with pkgs; [ hplip ];

  system.stateVersion = "23.05";
}
