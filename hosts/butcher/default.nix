{ pkgs, inputs, ...}: {

  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-hdd
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.nur.nixosModules.nur
    inputs.vscode-server.nixosModules.default
    ./hardware-configuration.nix
    ../common/global

    ../../users/dave
  ];

  boot = {
    initrd = {
      checkJournalingFS = false;
    };
    supportedFilesystems = [
      "btrfs"
      "fat" "vfat" "exfat" "ntfs" # Microsoft
    ];
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
        virtd = {
          client.enable = true;
          daemon.enable = true;
        };
      };
    };
    filesystem = {
      btrfs.enable = true;
      encryption.enable = true;
      impermanence = {
        enable = true;
        directories = [
          "/mnt/"
        ];
      };
    };
    hardware = {
      cpu = "vm-intel";
      sound.enable = false;
    };
    network = {
      vpn = {
        tailscale.enable = true;
      };
    };
    service = {
      vscode_server.enable = true;
    }
  };

  networking = {
    hostName = "butcher";
    dhcpcd.enable = false;
    enableIPv6 = false;
    useNetworkd = true;
    firewall.enable = false;
    interfaces.enp6s18.ipv4.addresses = [{
      address = "192.168.137.5";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.137.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };

  services.qemuGuest.enable = true;
  system.stateVersion = "23.11";
}
