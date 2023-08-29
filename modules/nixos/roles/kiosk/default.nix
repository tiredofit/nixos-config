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
        powermanagement = {
          enable = mkDefault false;
        };
      };
      hardware = {
        bluetooth.enable = mkDefault false;
        graphics = {
          enable = mkDefault true;
          acceleration = mkDefault true;
        };
        printing.enable = mkDefault false;
        sound.enable = mkDefault false;
        webcam.enable = mkDefault true;
        wireless.enable = mkDefault true;
        yubikey.enable = mkDefault true;
      };
    };

    powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  };
}