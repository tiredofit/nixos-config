{ config, pkgs, inputs, ...}: {

  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-cpu-amd-pstate
    inputs.hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.hardware.nixosModules.common-pc-hdd
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.nur.nixosModules.nur
    inputs.vscode-server.nixosModules.default
    ./hardware-configuration.nix

    ../common/global
    ../common/optional/gui/graphics-acceleration.nix
    ../common/optional/gui/x.nix

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
    hardware = {
      bluetooth.enable = true;
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


  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;   # stick with the stable track
  hardware.nvidia.modesetting.enable = true;                                    # enable kms
  system.stateVersion = "23.11";
}
