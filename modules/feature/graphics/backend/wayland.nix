{ config, inputs, lib, pkgs, specialArgs, ... }:
with lib;
let
  inherit (specialArgs) kioskUsername kioskURL;

  graphics = config.host.feature.graphics;
in {
  config = mkIf (graphics.enable && graphics.backend == "wayland") {
    environment.pathsToLink = [ "/libexec" ];

    programs = mkIf (config.host.role != "kiosk") {
      dconf.enable = mkDefault true;
      seahorse.enable = mkDefault true;
      hyprland = {
       enable = mkDefault true;
       package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      };
    };

    security = mkIf (config.host.role != "kiosk") {
      pam = {
        services.gdm.enableGnomeKeyring = mkDefault true;
        services.swaylock.text = mkDefault ''
         # PAM configuration file for the swaylock screen locker. By default, it includes
         # the 'login' configuration file (see /etc/pam.d/login)
         auth include login
       '';
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
          xterm.enable = false;
        };

        layout = mkDefault "us";
        libinput.enable = mkDefault true;
      };
    };

    #xdg = {
    #  portal = mkIf (config.host.role != "kiosk") {
    #    enable = true;
    #    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    #  };
    #};
  };
}