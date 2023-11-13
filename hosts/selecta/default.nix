{ inputs, pkgs, ...}: {

  imports = [
    inputs.nur.nixosModules.nur
    ./hardware-configuration.nix
    ../common
  ];

  host = {
    feature = {
      graphics = {
        enable = true;
        backend = "x";
      };
      virtualization = {
        virtd = {
          client.enable = true;
          daemon.enable = true;
        };
      };
    };
    filesystem = {
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "amd";
      gpu = "nvidia";
      sound = {
        server = "pulseaudio";
      };
    };
    role = "desktop";
    network = {
      hostname = "selecta";
    };
    user = {
      root.enable = true;
      dave.enable = true;
      media.enable = true;
    };
  };
}
