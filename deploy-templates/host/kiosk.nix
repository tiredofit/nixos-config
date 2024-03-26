{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    inputs.nur.nixosModules.nur
    ./disks.nix
    ../common
  ];

  host = {
    feature = {
      graphics = {
        enable = true;
        backend = "x";
      };
    };
    filesystem = {
      btrfs.enable = false;
    };
    network = {
      hostname = "kiosk-template";
    };
    role = "kiosk";
    user = {
      root.enable = true;
    };
  };
}
