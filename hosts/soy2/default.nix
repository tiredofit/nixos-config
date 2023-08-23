{ inputs, modulesPath, pkgs, ...}: {

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../templates/hardware/qemu-guest.nix

    inputs.disko.nixosModules.disko
    ../../templates/disko/efi-btrfs-swap.nix

    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-pc-hdd
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.nur.nixosModules.nur
    inputs.vscode-server.nixosModules.default
    #./hardware-configuration.nix

    ../common/global
    ../common/optional/gui/x.nix

    #../common/optional/plymouth.nix
    #../common/optional/tailscale.nix
    #../common/optional/virtualization-docker.nix

    ../../users/dave
  ];


  boot = {

    supportedFilesystems = [
      "btrfs"
      "fat" "vfat" "exfat" "ntfs" # Microsoft
    ];
  };

  hostoptions = {
    boot-efi.enable = true;
    btrfs.enable = true;
    encryption.enable = false;
    impermanence.enable = true;
    powermanagement.enable = true;
  };


  networking = {
    hostName = "soy";
    networkmanager = {
      enable = true;
    };
  };

  services.qemuGuest.enable = true;
  system.stateVersion = "23.11";
}
