{ lib, config, pkgs, ... }:

{
  # all fonts are linked to /nix/var/nix/profiles/system/sw/share/X11/fonts
  fonts = {
    # use fonts specified by user rather than default ones
    enableDefaultFonts = false;
    fontDir.enable = true;

    fonts = with pkgs; [
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
        "Hack"
      ];})
    ];

    # user defined fonts
    # the reason there's Noto Color Emoji everywhere is to override DejaVu's
    # B&W emojis that would sometimes show instead of some Color emojis
    fontconfig = {
      enable = true ;
      antialias = true;
      cache32Bit = true;
      hinting.enable = true;
      hinting.autohint = true;
      defaultFonts = {
        serif = [ "Noto Serif" "Noto Color Emoji" ];
        sansSerif = [ "Noto Sans" "Noto Color Emoji" ];
        monospace = [ "Hack Nerd Font" "Noto Color Emoji" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
