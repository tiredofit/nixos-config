{ config, inputs, lib, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    feature = {
    };
    filesystem = {
      encryption.enable = true;                 # This line can be removed if not needed as it is already default set by the role template
      impermanence.enable = true;               # This line can be removed if not needed as it is already default set by the role template
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "amd";
      raid.enable = true;                      # This line can be removed if not needed as it is already default set by the role template
    };
    network = {
      hostname = "entropy";
      wired = {
       enable = true;
       type = "static";
       ip = "148.113.218.18/32";
       gateway = "100.64.0.1";
       mac = "34:5a:60:00:9a:5c";
      };

    };
    role = "server";
    user = {
      root.enable = lib.mkDefault true;
      dave.enable = lib.mkDefault true;
    };
  };
}
