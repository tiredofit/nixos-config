{ inputs, pkgs, ...}: {

  imports = [
    inputs.nur.nixosModules.nur

    ./hardware-configuration.nix
    ../common/global
  ];


  host = {
    filesystem = {
      encryption.enable = false;
      swap = {
        partition = "disk/by-uuid/c49b427e-53a4-4224-9c3a-d0d9daf2ba72";
      };
    };
    hardware = {
      cpu = "vm-intel";
    };
    role = "server";
    service = {
      vscode_server.enable = true;
    };
    user = {
      dave.enable = true;
      root.enable = false;
    };
  };

  networking = {
    hostName = "butcher";
    interfaces.enp6s18.ipv4.addresses = [{
      address = "192.168.137.5";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.137.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };

  services.qemuGuest.enable = true;
}
