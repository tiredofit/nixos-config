{ inputs, modulesPath, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ../../templates/disko/efi-btrfs-impermanence-swap.nix
    ../../templates/machine/virtd-vm.nix
    inputs.nur.nixosModules.nur

    ../common/global
    ../../users/dave
    ../../users/root
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
      impermanence.enable = true;
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
