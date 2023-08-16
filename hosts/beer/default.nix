{ config, pkgs, ... }:
let
 resolutionfix = pkgs.writeShellScriptBin "resolution_fix" ''
    sudo cvt 2560 1080 60
    sudo xrandr --newmode "2560x1080_60.00"  230.00  2560 2720 2992 3424 1080 1083 1093 1120 -hsync +vsync
    sudo xrandr --addmode HDMI-1 2560x1080_60.00
  '';
in
{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/nixos/default.nix
      ../../modules/nixos/services/openssh.nix
      ../../modules/nixos/gui/x-kiosk.nix
    ];

  boot = {
    loader = {
      generic-extlinux-compatible.enable = true;
      grub.enable = false;
    };
    kernelParams = [ "video=2560x1080@60" ];
    kernelPackages = pkgs.linuxPackages_latest;  # Latest kernel
  };

  networking = {
    hostName = "beer";
    networkmanager= {
      enable = true;
      wifi.backend = "iwd";
    };
  };

  nix.settings.trusted-users = [ "root" "@wheel" "dave" ];
  system.stateVersion = "23.11";

  services.xserver = {
    videoDrivers = [ "fbdev" ];
  };

  environment.systemPackages = with pkgs; [
    arandr
    libraspberrypi
    xterm
    xorg.libxcvt
    resolutionfix
  ];
}


