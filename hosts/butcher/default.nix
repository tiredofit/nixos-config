{ inputs, pkgs, ...}: {

  imports = [
    inputs.nur.nixosModules.nur

    ./hardware-configuration.nix
    ../common/global

    ../../users/dave
  ];


  host = {
    filesystem = {
      encryption.enable = false;
    };
    hardware = {
      cpu = "vm-intel";
    };
    role = "server";
    service = {
      vscode_server.enable = true;
    }
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
