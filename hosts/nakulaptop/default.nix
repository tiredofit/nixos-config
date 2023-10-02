{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.nur.nixosModules.nur
    ./hardware-configuration.nix

    ../common/global
  ];

  boot = {
    kernelParams = [
    ];
  };

  host = {
    feature = {
      gaming = {
        enable = true;
        steam = {
          enable = true;
          protonGE = true;
        };
      };
      graphics = {
        enable = true;
        backend = "x";
      };
    };
    filesystem = {
      swap = {
        partition = "disk/by-uuid/0839e935-d57b-4384-9d48-f557d0250ec1";
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
      hostname = "nakulaptop";
    };
    role = "laptop";
    user = {
      dave.enable = true;
      ireen.enable = true;
      root.enable = true;
    };
  };
}
