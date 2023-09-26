{ config, lib, modulesPath, pkgs, ... }:
let
  role = config.host.role;
in
  with lib;
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./power
  ];

  config = mkIf (role == "laptop" || role == "hybrid") {
    host = {
      feature = {
        boot = {
          efi.enable = mkDefault true;
          graphical.enable = mkDefault true;
        };
        fonts = {
          enable = mkDefault true;
        };
        graphics = {
          enable = mkDefault true;            # We're working with a GUI here
          acceleration = mkDefault true;      # Since we have a GUI, we want openGL
        };
        powermanagement = {
          enable = true;
          laptop = true;
        };
      };
      filesystem = {
        btrfs.enable = mkDefault true;
        encryption.enable = mkDefault true;
        impermanence.enable = mkDefault true;
        swap = {
          enable = mkDefault false;
          type = mkDefault "file";
        };
      };
      hardware = {
        bluetooth.enable = mkDefault true;    # Most wireless cards have bluetooth radios
        raid.enable = mkDefault false;        #
        printing.enable = mkDefault true;     # If we don't have access to a physical printer we should be able to remotely print
        scanning.enable = mkDefault true;
        sound.enable = mkDefault true;        #
        touchpad.enable = mkDefault true;     # We want this most of the time
        webcam.enable = mkDefault true;       # Age of video conferencing
        wireless.enable = mkDefault true;     # Most systems have some sort of 802.11
        yubikey.enable = mkDefault true;      #
      };
    };

    networking = {
      networkmanager= {
        enable = mkDefault true;
      };
    };
  };
}