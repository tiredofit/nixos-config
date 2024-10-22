{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    feature = {
    };
    container = {
      clamav = {
        enable = true;
        logship = "false";
        monitor = "false";
      };
      restic = {
        enable = true;
        logship = "false";
        monitor = "false";
      };
      socket-proxy = {
        enable = true;
        logship = "false";
        monitor = "false";
      };
      traefik = {
        enable = true;
        logship = "false";
        monitor = "false";
      };
      unbound = {
        enable = true;
        logship = "false";
        monitor = "false";
      };
    };
    filesystem = {
      encryption.enable = true;                 # This line can be removed if not needed as it is already default set by the role template
      impermanence.enable = true;               # This line can be removed if not needed as it is already default set by the role template
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "amd";
      raid.enable = true;                      # This line can be removed if not needed as it is already default set by the role template
    };
    network = {
      hostname = "seed";
      wired = {
       enable = true;
       type = "static";
       ip = "148.113.187.218/32";
       gateway = "100.64.0.1";
       mac = "0f:7c:16:f1:1a:fe";
      };
    };
    role = "server";
    service = {
      vscode_server.enable = true;
    };
    user = {
      root.enable = true;
      dave.enable = true;
    };
  };
}
