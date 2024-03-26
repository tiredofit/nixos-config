{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    inputs.nur.nixosModules.nur
    ./disks.nix
    ../common
  ];

  host = {
    feature = {
    };
    filesystem = {
      encryption.enable = true;   # This line can be removed if not needed as it is already default set by the role template
      impermanence.enable = true; # This line can be removed if not needed as it is already default set by the role template
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "amd";
      raid.enable = false;        # This line can be removed if not needed as it is already default set by the role template
    };
    network = {
      hostname = "server-template";
      wired = {
        enable = true;             # This line can be removed if not using wired networking
        type = "dynamic";
        ip = "000.000.000.000/0";
        gateway = "000.000.000.000";
        mac = "A1:B2:C3:D4:E5";
      };
    };
    role = "server";
    user = {
      root.enable = true;
      dave.enable = true;
    };
  };
}
