{ inputs, modulesPath, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ../../templates/disko/efi-btrfs-swap.nix
    ../../templates/hardware/vm-qemu.nix
    inputs.nur.nixosModules.nur

    #./hardware-configuration.nix

    ../common/global
    ../../users/dave
  ];

  host = {
    feature = {
      boot = {
        efi.enable = true;
      };
      powermanagement.enable = true;
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
    role = "lite";
  };

  networking = {
    hostName = "disko";
  };
}
