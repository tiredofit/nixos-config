{ config, lib, modulesPath, pkgs, ... }:
let
  role = config.host.role;
in
  with lib;
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  config = mkIf (role == "desktop") {
    host = {
      feature = {
        boot = {
          efi.enable = mkDefault true;
          graphical.enable = mkDefault true;
        };
        development = {
          crosscompilation = {
            enable = mkDefault true;
            platform = "aarch64-linux";
          };
        };
        fonts = {
          enable = mkDefault true;
        };
        graphics = {
          enable = mkDefault true;            # We're working with a GUI here
          acceleration = mkDefault true;      # Since we have a GUI, we want openGL
        };
        powermanagement.enable = mkDefault true;
        virtualization = {
          docker = {
            enable = mkDefault true;
          };
          virtd = {
            client.enable = mkDefault true;
            daemon.enable = mkDefault true;
          };
        };
      };
      filesystem = {
        btrfs.enable = mkDefault true;
        encryption.enable = mkDefault false;
        impermanence = {
          enable = mkDefault true;
          directories = [

          ];
        };
        swap = {
          enable = mkDefault true;
          type = mkDefault "partition";
        };
        tmp.tmpfs.enable = mkDefault true;
      };
      hardware = {
        android.enable = mkDefault true;
        bluetooth.enable = mkDefault true;    # Most wireless cards have bluetooth radios
        printing.enable = mkDefault true;     # If we don't have access to a physical printer we should be able to remotely print
        raid.enable = mkDefault false;
        scanning.enable = mkDefault true;
        sound.enable = mkDefault true;        #
        webcam.enable = mkDefault true;       # Age of video conferencing
        wireless.enable = mkDefault true;     # Most systems have some sort of 802.11
        yubikey.enable = mkDefault true;      #
      };
      network = {
        firewall = {
          fail2ban.enable = mkDefault true;     #
          opensnitch.enable = mkDefault false;  # Only activated by opensnitch-ui
        };
        vpn = {
          tailscale.enable = mkDefault true;
        };
      };
      service = {
        logrotate.enable = mkDefault true;
        ssh = {
          enable = mkDefault true;
          harden = mkDefault true;
        };
        vscode_server.enable = true;
      };
    };

    networking = {
      networkmanager= {
        enable = mkDefault true;
      };
    };
 };
}