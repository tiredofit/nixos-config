{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/2116df83-e8d7-4dfb-85ba-0c3d602c7d90";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  boot.initrd.luks.devices."pool0_0".device = "/dev/disk/by-uuid/8fbd9528-3a3b-4e69-97d4-7befe33e4305";
  boot.initrd.luks.devices."pool0_1".device = "/dev/disk/by-uuid/bf6d202c-c8ad-4415-9b7b-b70addad6d7b";
  boot.initrd.luks.devices."swap".device = "/dev/disk/by-uuid/bea444f7-fe48-4837-9db6-8c23d8b3ee26";

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

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/2116df83-e8d7-4dfb-85ba-0c3d602c7d90";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/persist" =
    { device = "/dev/disk/by-uuid/2116df83-e8d7-4dfb-85ba-0c3d602c7d90";
      fsType = "btrfs";
      options = [ "subvol=persist" ];
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
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
