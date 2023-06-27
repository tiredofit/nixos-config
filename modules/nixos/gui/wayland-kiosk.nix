{ config, pkgs, specialArgs, ... }:
let
  inherit (specialArgs) kioskUsername kioskURL;
in
{
  imports =
    [
#      ./fonts.nix
      ../locale.nix
    ];

  services.cage = {
    enable = true;
    user = "${kioskUsername}";
    program = "${pkgs.firefox}/bin/firefox -kiosk -private-window ${kioskURL}";
  };
}

