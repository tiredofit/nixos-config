{config, lib, pkgs, ...}:

let
  cfg = config.host.feature.virtualization.flatpak;
in
  with lib;
{
  options = {
    host.feature.virtualization.flatpak = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable support for Flatpak containerization";
      };
    };
  };

  config = mkIf cfg.enable {
    fileSystems = let
      mkRoSymBind = path: {
        device = path;
        fsType = "fuse.bindfs";
        options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
      };
      aggregatedFonts = pkgs.buildEnv {
        name = "system-fonts";
        paths = config.fonts.packages;
        pathsToLink = [ "/share/fonts" ];
      };
    in {
      # Create an FHS mount to support flatpak host icons/fonts
      #"/usr/share/icons" = mkRoSymBind (config.system.path + "/share/icons");
      "/usr/share/fonts" = mkRoSymBind (aggregatedFonts + "/share/fonts");
    };

    host.filesystem.impermanence.directories = lib.mkIf config.host.filesystem.impermanence.enable [
      "/var/lib/flatpak"                 # Flatpak
    ];

    services.flatpak.enable = true;
    system.fsPackages = [ pkgs.bindfs ];

    xdg.portal = {
      enable = mkDefault true;
      config.common = mkDefault {
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        "org.freedesktop.portal.FileChooser" = [ "xdg-desktop-portal-gtk" ];
      };
      #extraPortals = with pkgs; [
      #   xdg-desktop-portal-gtk
      #];
    };
  };
}
