 {config, lib, pkgs, ...}:

let
  cfg = config.host.feature.fonts;
  graphics = config.host.feature.graphics;
in
  with lib;
{
  options = {
    host.feature.fonts = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable Fonts";
      };
    };
  };

  config = mkIf cfg.enable {
  # all fonts are linked to /nix/var/nix/profiles/system/sw/share/X11/fonts
    fonts = mkIf graphics.enable {
      # use fonts specified by user rather than default ones
      enableDefaultPackages = false;
      fontDir.enable = true;

      packages = with pkgs; [
        caladea
        cantarell-fonts
        carlito
        courier-prime
        dejavu_fonts
        font-awesome
        gelasio
        liberation_ttf
        material-design-icons
        merriweather
        noto-fonts
        noto-fonts-emoji
        open-sans
        roboto
        ubuntu_font_family
        weather-icons

        # nerdfonts
        (nerdfonts.override { fonts = [
          "DroidSansMono"
          "Hack"
          "JetBrainsMono"
          "Noto"
        ];})
      ];

      # user defined fonts
      # the reason there's Noto Color Emoji everywhere is to override DejaVu's
      # B&W emojis that would sometimes show instead of some Color emojis
      fontconfig = mkIf graphics.enable {
        enable = mkDefault true;
        antialias = mkDefault true;
        cache32Bit = mkDefault true;
        hinting.enable = mkDefault true;
        hinting.autohint = mkDefault true;
        defaultFonts = {
          serif = [ "Noto Serif NF" "Noto Color Emoji" ];
          sansSerif = [ "Noto Sans NF" "Noto Color Emoji" ];
          monospace = [ "Hack Nerd Font" "Noto Color Emoji" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
  };
}
