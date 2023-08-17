{ pkgs, inputs, ...}: {

  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-hdd
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.nur.nixosModules.nur

    ./hardware-configuration.nix
    ../common/global

    ../common/optional/virtualization-docker.nix
    ../common/optional/vscode-server.nix

    ../common/users/dave
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

  hostoptions = {
    boot-efi.enable = true;
    btrfs.enable=true;
    impermanence = {
      enable = true;
      directories = [
        "/mnt/"
      ];
    services.docker_container_manager = true;
    };

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
