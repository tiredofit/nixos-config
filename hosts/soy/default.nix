{ inputs, pkgs, modulesPath, ...}: {

  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-pc-hdd
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.nur.nixosModules.nur
    inputs.vscode-server.nixosModules.default
    ./hardware-configuration.nix

    ../common/global
    ../common/optional/gui/x.nix

    ../common/optional/plymouth.nix
    ../common/optional/tailscale.nix
    ../common/optional/virtualization-docker.nix

    ../../users/dave
  ];


  boot = {

    kernelParams = [ "resume_offset=4503599627370495" ];                        # Hibernation 'btrfs inspect-internal map-swapfile -r /mnt/swap/swapfile'
    resumeDevice = "/dev/disk/by-uuid/558e1b77-4ddc-4080-82e7-ecfb4045a79d" ;   # Hibernation 'blkid | grep '/dev/mapper/pool0_0' | awk '{print $2}' | cut -d '"' -f 2)'

    supportedFilesystems = [
      "btrfs"
      "fat" "vfat" "exfat" "ntfs" # Microsoft
      "cifs"                      # Windows Network Share
    ];
  };

  host = {
    feature = {
      encryption.enable = true;
      impermanence.enable = true;
      powermanagement.enable = true;
    };
  };

  hostoptions = {
    boot-efi.enable = true;
    btrfs.enable=true
  };

  networking = {
    hostName = "soy";
    networkmanager= {
      enable = true;
    };
  };

  services.qemuGuest.enable = true;
  system.stateVersion = "23.11";
}
