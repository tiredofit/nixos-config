# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/8f68194f-5a41-4216-bebf-2a342f318395";
      fsType = "btrfs";
      options = [ "subvol=root/active" ];
    };

  fileSystems."/.snapshots" =
    { device = "/dev/disk/by-uuid/8f68194f-5a41-4216-bebf-2a342f318395";
      fsType = "btrfs";
      options = [ "subvol=root/snapshots" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/7E90-DA96";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/8f68194f-5a41-4216-bebf-2a342f318395";
      fsType = "btrfs";
      options = [ "subvol=home/active" ];
    };

  fileSystems."/home/.snapshots" =
    { device = "/dev/disk/by-uuid/8f68194f-5a41-4216-bebf-2a342f318395";
      fsType = "btrfs";
      options = [ "subvol=home/snapshots" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/8f68194f-5a41-4216-bebf-2a342f318395";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/var/local" =
    { device = "/dev/disk/by-uuid/8f68194f-5a41-4216-bebf-2a342f318395";
      fsType = "btrfs";
      options = [ "subvol=var_local/active" ];
    };

  fileSystems."/var/local/.snapshots" =
    { device = "/dev/disk/by-uuid/8f68194f-5a41-4216-bebf-2a342f318395";
      fsType = "btrfs";
      options = [ "subvol=var_local/snapshots" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/8f68194f-5a41-4216-bebf-2a342f318395";
      fsType = "btrfs";
      options = [ "subvol=var_log" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/6402c381-6c93-4673-a78e-250752f15c9b"; }
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}