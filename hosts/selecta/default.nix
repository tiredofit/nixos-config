{ inputs, pkgs, ...}: {

  imports = [
    inputs.nur.nixosModules.nur
    ./hardware-configuration.nix

    ../common/global

    ../../users/dave
    ../../users/root
  ];

  host = {
    graphics = {
      displayServer = "x";
    };
    hardware = {
      cpu = "amd";
      graphics = {
        enable = true;
        acceleration = true;
        gpu = "nvidia";
      }
      sound = {
        server = "pulseaudio";
      };
    };
    role = "desktop";
  };

  networking = {
    hostName = "selecta";
  };
}
