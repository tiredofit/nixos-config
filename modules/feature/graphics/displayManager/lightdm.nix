{ config, lib, pkgs, ... }:

let
  graphics = config.host.feature.graphics;
  displayManager = config.host.feature.graphics.displayManager.lightdm;
  wayland =
    if (graphics.backend == "wayland")
    then true
    else false;
in
with lib;
{
  options = {
    host.feature.graphics.displayManager.lightdm = {
      greeter = {
        name = mkOption {
          type = types.enum ["enso" "gtk" "mini" "mobile" "pantheon" "slick" "tiny"];
          default = "enso";
          description = "LightDM Greeter to use";
        };
        enso = mkOption {
          blur = mkOption {
            type = types.bool;
            default = false;
            description = "Whether or not to enable blur";
          };
          brightness = mkOption {
            type = types.int;
            default = 7;
            description = "Brightness";
          };
          extraConfig = mkOption {
            type = types.lines;
            default = "";
            description = "Extra configuration that should be put in the greeter configuration file";
          };
        };
      };
      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = "Extra configuration that should be put in the greeter configuration file";
      };
      theme = {
        background = mkOption {
          type = types.either types.path (types.strMatching "^#[0-9]\{6\}$");
          defaultText = literalExpression "pkgs.nixos-artwork.wallpapers.simple-dark-gray-bottom.gnomeFilePath";
          description = "The background image or color to use.";
          default = "#000000";
        };
        cursor = {
          name = mkOption {
            type = with types; str;
            description = "Cursor theme";
            example = "Adwaita";
            default = "Adwaita-Dark";
          };
          package = mkOption {
            type = with types; package;
            description = "Package Name for cursor theme";
            example = "pkgs.gnome.adwaita-icon-theme";
            default = pkgs.gnome.adwaita-icon-theme;
          };
          size = mkOption {
            type = with types; int;
            description = "Size of cursor";
            example = "24";
            default = 24;
          };
        };
        font = {
          name = mkOption {
            type = with types; str;
            description = "Name of the font to use";
            example = "Ubuntu 11";
            default = "Ubuntu 11";
          };
          package = mkOption {
            type = with types; package;
            description = "Package path that contains the font";
            example = "pkgs.ubuntu_font_family";
            default = pkgs.ubuntu_font_family;
          };
        };
        icon = {
          name = mkOption {
            type = with types; str;
            description = "Icon theme";
            example = "Adwaita";
            default = "Quintom_Snow";
          };
          package = mkOption {
            type = with types; package;
            description = "Package Name for cursor theme";
            example = "pkgs.gnome.adwaita-icon-theme";
            default = pkgs.quintom-cursor-theme;
          };
        };
        name = mkOption {
          type = with types; str;
          description = "Theme for greeter";
          example = "Adwaita";
          default = "Adwaita-Dark";
        };
        package = mkOption {
          type = with types; package;
          description = "Package Name for cursor theme";
          example = "pkgs.gnome.gnome-themes-extra";
          default = pkgs.gnome.gnome-themes-extra;
        };
      };
    };
  };
  config = mkIf (graphics.enable && graphics.displayManager.manager == "lightdm") {
    services = {
      xserver = {
        displayManager = {
          lightdm = {
            enable = mkDefault true;
            background = displayManager.theme.background;
            greeters = {
              enso = mkIf (displayManager.greeter == "enso") {
                enable = mkDefault true;
                extraConfig = displayManager.extraConfig;
                #blur = displayManager.greeter.enso.blur;
                brightness = displayManager.greeter.enso.brightness;
                theme = {
                  name = displayManager.theme.name;
                  package = displayManager.theme.package;
                };
                cursorTheme = {
                  name = displayManager.theme.cursor.name;
                  package = displayManager.theme.cursor.package;
                };
                iconTheme = {
                  name = displayManager.theme.icon.name;
                  package = displayManager.theme.icon.package;
                };
              };
              gtk = mkIf (displayManager.greeter == "gtk") {
                enable = mkDefault true;
                extraConfig = displayManager.extraConfig;
                theme = {
                  name = displayManager.theme.name;
                  package = displayManager.theme.package;
                };
                cursorTheme = {
                  name = displayManager.theme.cursor.name;
                  package = displayManager.theme.cursor.package;
                  size = displayManager.theme.cursor.size;
                };
                iconTheme = {
                  name = displayManager.theme.icon.name;
                  package = displayManager.theme.icon.package;
                };
              };
              mini = mkIf (displayManager.greeter == "mini") {
                enable = mkDefault true;
              };
              mobile = mkIf (displayManager.greeter == "mobile") {
                enable = mkDefault true;
              };
              pantheon = mkIf (displayManager.greeter == "pantheon") {
                enable = mkDefault true;
              };
              slick = mkIf (displayManager.greeter == "slick") {
                enable = mkDefault true;
                extraConfig = displayManager.extraConfig;
                theme = {
                  name = displayManager.theme.name;
                  package = displayManager.theme.package;
                };
                cursorTheme = {
                  name = displayManager.theme.cursor.name;
                  package = displayManager.theme.cursor.package;
                  size = displayManager.theme.cursor.size;
                };
                font = {
                  name = displayManager.theme.font.name;
                  package = displayManager.theme.font.package;
                };
                iconTheme = {
                  name = displayManager.theme.icon.name;
                  package = displayManager.theme.icon.package;
                };
              };
              tiny = mkIf (displayManager.greeter == "tiny") {
                enable = mkDefault true;
              };
            };
          };
        };
      };
    };
  };
}
