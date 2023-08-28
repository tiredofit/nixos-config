{ config, lib, pkgs, ... }:
let
  role = config.host.role;
in
  with lib;
{
  config = mkIf (role == "minimal") {
    host = {
      hardware = {
        bluetooth.enable = mkDefault false;
        graphics = {
          enable = mkDefault false;
          acceleration = mkDefault true;
        };
        printing.enable = mkDefault false;
        sound.enable = mkDefault false;
        webcam.enable = mkDefault false;
        wireless.enable = mkDefault false;
        yubikey.enable = mkDefault false;
      };
    };
  };
}