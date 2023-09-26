{ config, lib, modulesPath, pkgs, ... }:
let
  role = config.host.role;
in
  with lib;
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")

  ];

  ## TODO Need to come up with a better naming structure as this doesn't support nested options
  #options = {
  #  host.role.kiosk.browser = mkOption {
  #    type = types.enum ["firefox" "chromium"];
  #    default = "firefox";
  #    description = "URL to visit on browser";
  #    };
  #  host.role.kiosk.url = mkOption {
  #    type = types.str;
  #    default = "https://tiredofit.ca";
  #    description = "URL to visit on browser";
  #  };
  #};

  config = mkIf (role == "kiosk") {
    host = {
      feature = {
        boot = {
          efi.enable = mkDefault false;
          graphical.enable = mkDefault false;
        };
        fonts = {
          enable = mkDefault true;
        };
        graphics = {
          enable = mkDefault true;
          acceleration = mkDefault true;
        };
        powermanagement = {
          enable = mkDefault false;
        };
      };
      filesystem = {
        btrfs.enable = mkDefault false;
        encryption.enable = mkDefault false;
        impermanence = {
          enable = mkDefault false;
          directories = [

          ];
        };
        swap = {
          enable = mkDefault false;
        };
      };
      hardware = {
        bluetooth.enable = mkDefault false;
        printing.enable = mkDefault false;
        raid.enable = mkDefault false;
        scanning.enable = mkDefault false;
        sound.enable = mkDefault false;
        webcam.enable = mkDefault true;
        wireless.enable = mkDefault true;
        yubikey.enable = mkDefault true;
      };
    };

    powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  };
}