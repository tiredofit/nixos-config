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
      encryption.enable = false;                 # This line can be removed if not needed as it is already default set by the role template
      impermanence.enable = true;               # This line can be removed if not needed as it is already default set by the role template
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "intel";
      raid.enable = true;                      # This line can be removed if not needed as it is already default set by the role template
    };
    network = {
      hostname = "seed";
      wired = {
       enable = true;
       type = "static";
       ip = "149.56.29.182/24";
       gateway = "149.56.29.254";
       mac = "a8:a1:59:c2:28:e6";
      };

    };
    role = "server";
    user = {
      root.enable = true;
      dave.enable = true;
    };
  };
}
