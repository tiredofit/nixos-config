{ inputs, pkgs, ...}: {

  imports = [
    inputs.nur.nixosModules.nur
    ./hardware-configuration.nix

    ../common/global

    ../../users/dave
  ];


  boot = {
    kernelParams = [ "resume_offset=4503599627370495" ];                        # Hibernation 'btrfs inspect-internal map-swapfile -r /mnt/swap/swapfile'
    resumeDevice = "/dev/disk/by-uuid/558e1b77-4ddc-4080-82e7-ecfb4045a79d" ;   # Hibernation 'blkid | grep '/dev/mapper/pool0_0' | awk '{print $2}' | cut -d '"' -f 2)'
  };

  host = {
    feature = {
      boot = {
        efi.enable = true;
      };
      powermanagement.enable = true;
      virtualization = {
        docker = {
          enable = true;
        };
      };
    };
    filesystem = {
      btrfs.enable = true;
      encryption.enable = true;
      impermanence.enable = true;
    };
    hardware = {
      cpu = "vm-amd";
      graphics = {
        enable = true;
        displayServer = "x";
      };
      raid.enable = true;
      sound = {
        server = "pulseaudio";
      };
    };
    role = "vm";
  };

  networking = {
    hostName = "soy";
  };
}
