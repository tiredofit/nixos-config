{ inputs, modulesPath, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ../../templates/disko/efi-btrfs-swap.nix
    ../../templates/machine/virtd-vm.nix
    inputs.nur.nixosModules.nur

    #./hardware-configuration.nix

    ../common/global
    ../../users/dave
  ];

  host = {
    feature = {
      graphics = {
        enable = false;
      };
    };
    filesystem = {
      btrfs.enable = true;
      encryption.enable = false;
      impermanence.enable = false;
    };
    hardware = {
      cpu = "vm-amd";
      raid.enable = true;
      sound = {
        enable = false;
        server = "pulseaudio";
      };
    };
    role = "vm";
  };

  networking = {
    hostName = "disko";
  };
}
