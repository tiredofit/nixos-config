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
      encryption.enable = true;
      impermanence.enable = true;
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "amd";
      raid.enable = true;
    };
    network = {
      hostname = "seed";
      wired = {
       enable = true;
       type = "static";
       ip = "148.113.187.218/32";
       gateway = "100.64.0.1";
       mac = "04:7c:16:f1:1a:fe";
      };
    };
    role = "server";
    service = {
      container-dns-companion = {
        enable = true;
        general = {
          log_level = "debug";
        };
        polls = {
          docker = {
            type = "docker";
          };
        };
      };
      iodine.enable = false;
      vscode_server.enable = true;
    };
    user = {
      root.enable = true;
      dave.enable = true;
    };
  };
}
