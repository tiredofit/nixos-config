{ config, pkgs, inputs, ...}: {

  imports = [
    inputs.nur.nixosModules.nur
    ./hardware-configuration.nix

    ../common/global

    ../../users/dave
    ../../users/root
  ];

  boot = {
    kernelParams = [
      "quiet"
    ];
  };

  host = {
    feature = {
      boot = {
        efi.enable = true;
        graphical.enable = true;
      };
      powermanagement.enable = true;
      virtualization = {
        docker = {
          enable = true;
        };
        virtd = {
          client.enable = true;
          daemon.enable = true;
        };
      };
    };
    filesystem = {
      btrfs.enable = true;
      encryption.enable = true;
      impermanence.enable = true;
    };
    graphics = {
      enable = true;
      displayServer = "x";
    };
    hardware = {
      bluetooth.enable = true;
      cpu = "amd";
      graphics = {
        enable = true;
        acceleration = true;
        gpu = "nvidia";
      }
      printing.enable = true;
      raid.enable = true;
      sound = {
        enable = true;
        server = "pulseaudio";
      };
      wireless.enable = true;
    };
    network = {
      vpn = {
        tailscale.enable = true;
      };
    };
  };

  networking = {
    hostName = "selecta";
    networkmanager= {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
