{ config, lib, modulesPath, pkgs, ... }:
let
  role = config.host.role;
in
  with lib;
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  config = mkIf (role == "console") {
    host = {
      feature = {
        boot = {
          efi.enable = mkDefault true;
          graphical.enable = mkDefault false;
        };
        fonts = {
          enable = mkDefault false;
        };
        graphics = {
          enable = mkDefault false;
          acceleration = mkDefault true;
        };
      };
      filesystem = {
        btrfs.enable = mkDefault true;
        encryption.enable = mkDefault false;
        impermanence = {
          enable = mkDefault true;
          directories = [
            "/mnt/"
          ];
        };
        swap = {
          type = "partition";
          enable = mkDefault false;
        };
      };
      hardware = {
        bluetooth.enable = mkDefault true;
        printing.enable = mkDefault false;
        raid.enable = mkDefault false;
        scanning.enable = mkDefault false;
        sound.enable = mkDefault true;
        webcam.enable = mkDefault false;
        wireless.enable = mkDefault true;
        yubikey.enable = mkDefault false;
      };
      network = {
        firewall.fail2ban.enable = mkDefault false;
      };
      service = {
        logrotate.enable = mkDefault true;
        ssh = {
          enable = mkDefault true;
          harden = mkDefault true;
        };
      };
    };
  };
}