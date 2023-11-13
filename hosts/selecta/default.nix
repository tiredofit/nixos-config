{ inputs, pkgs, ...}: {

  imports = [
    inputs.nur.nixosModules.nur
    ./hardware-configuration.nix
    ../common
  ];

  host = {
    feature = {
      graphics = {
        enable = true;
        backend = "x";
      };
      virtualization = {
        docker = {
          enable = false;
        };
        virtd = {
          client.enable = true;
          daemon.enable = true;
        };
      };
    };
    filesystem = {
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "amd";
      gpu = "nvidia";
      sound = {
        server = "pulseaudio";
      };
      scanning.enable = false;
      yubikey.enable = false;
    };
    role = "desktop";
    network = {
      firewall = {
        fail2ban.enable = false;
      };
      hostname = "selecta";
      vpn = {
        tailscale.enable = false;
      };
    };
    user = {
      root.enable = true;
      dave.enable = true;
      media.enable = true;
    };
  };
}
