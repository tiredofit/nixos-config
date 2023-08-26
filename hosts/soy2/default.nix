{ inputs, modulesPath, pkgs, ...}: {

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../templates/hardware/qemu-guest.nix

    inputs.disko.nixosModules.disko
    ../../templates/disko/efi-btrfs-swap.nix

    inputs.nur.nixosModules.nur

    #./hardware-configuration.nix

    ../common/global
    ../../users/dave
  ];


  boot = {

    supportedFilesystems = [
      "btrfs"
      "fat" "vfat" "exfat" "ntfs" # Microsoft
    ];
  };

  host = {
    feature = {
      boot = {
        efi.enable = true;
      };
      powermanagement.enable = true;
      virtualization = {
        docker = {
          enable = true;
        };
      };
    };
    filesystem = {
      btrfs.enable = true;
      encryption.enable = true;
      impermanence.enable = true;
    };
    hardware = {
      cpu = "vm-amd";
      graphics = {
        enable = true;
        displayServer = "x";
      };
      raid.enable = true;
      sound = {
        enable = true;
        server = "pulseaudio";
      };
    };
  };

  networking = {
    hostName = "soy";
    networkmanager = {
      enable = true;
    };
  };

  services.qemuGuest.enable = true;
  system.stateVersion = "23.11";
}
