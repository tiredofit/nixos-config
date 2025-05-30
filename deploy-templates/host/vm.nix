{ config, inputs, lib, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    feature = {
      graphics = {
        enable = true;
        backend = "wayland";
      };
    };
    filesystem = {
      encryption.enable = false;                # This line can be removed if not needed as it is already default set by the role template
      impermanence.enable = true;               # This line can be removed if not needed as it is already default set by the role template
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "amd-vm";
      gpu = "integrated-amd";
      raid.enable = false;                      # This line can be removed if not needed as it is already default set by the role template
      sound = {
        server = "pipewire";
      };
    };
    network = {
      hostname = "vm-template";
    };
    role = "vm";
    user = {
      root.enable = lib.mkDefault true;
      dave.enable = lib.mkDefault true;
    };
  };
}
