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
      wired.enable = false;             # This line can be removed if not using wired networking
    };
    role = "kiosk";
    user = {
      dave.enable = true;
      root.enable = true;
    };
  };
}
