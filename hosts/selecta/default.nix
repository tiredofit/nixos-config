{ inputs, pkgs, ...}: {

  imports = [
    inputs.nur.nixosModules.nur
    ./hardware-configuration.nix

    ../common

    ../../users/dave
    ../../users/root
  ];

  host = {
    feature = {
      graphics = {
        enable = true;
        backend = "x";
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
      hostname = "selekta";
    };
    user = {
      dave.enable = true;
      root.enable = true;
    };
  };
}
