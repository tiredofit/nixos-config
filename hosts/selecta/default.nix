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

    ../common/optional/plymouth.nix
    ../common/optional/services/virtualization-docker.nix
    ../common/optional/services/virtualization-virt-manager.nix

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
      encryption.enable = true;
      impermanence.enable = true;
    };

    hardware = {
      bluetooth.enable = true;
      printing.enable = true;
      wireless.enable = true;
    };
  };

  hostoptions = {
    boot-efi.enable = true;
    btrfs.enable = true;
    impermanence.enable = true;
    powermanagement.enable = true;
    raid.enable = false;
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
