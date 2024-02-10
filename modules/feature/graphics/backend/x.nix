{ config, lib, pkgs, specialArgs, ... }:
with lib;
let
  graphics = config.host.feature.graphics;
in {
  config = mkIf (graphics.enable && graphics.backend == "x") {
    environment.pathsToLink = [ "/libexec" ];
    programs = {
      dconf.enable = mkDefault true;
      seahorse.enable = mkDefault true;
    };

    security = {
      pam = {
        services.gdm.enableGnomeKeyring = mkDefault true;
      };
      polkit = {
        enable = mkDefault true;
      };
    };

    services = {
      gvfs = {
        enable = mkDefault true;
      };

      gnome.gnome-keyring = {
        enable = mkDefault true;
      };

      xserver = {
        enable = mkDefault true;
        desktopManager = {
          xterm.enable = mkDefault false;
        };
        libinput.enable = mkDefault true;
        xkb.layout = mkDefault "us";
      };
    };
  };
}
