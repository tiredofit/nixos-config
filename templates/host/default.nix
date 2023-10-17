{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.nur.nixosModules.nur
    ./disks.nix
    ../common/global
  ];

  host = {
    feature = {
      graphics = {
        enable = true;
        backend = "x";
      };
    };
    filesystem = {
      swap = {
        partition = "disk/by-label/SWAP";
      };
    };
    hardware = {
      cpu = "amd";
      gpu = "integrated-amd";
      sound = {
        server = "pulseaudio";
      };
    };
    network = {
      hostname = "DEFAULT";
    };
    role = "server";
    user = {
      root.enable = true;
    };
  };
}
