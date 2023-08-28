{ config, lib, pkgs, ... }:
let
  role = config.host.role;
in
  with lib;
{
  config = mkIf (role == "kiosk") {
    host = {
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
        ## TODO add host.role.kiosk.url and host.role.kiosk.browser
        ## TODO Setup documentation.enable and settings for different roles
    };
  };
}