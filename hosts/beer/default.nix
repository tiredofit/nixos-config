{ config, pkgs, ... }:
let
 resolutionfix = pkgs.writeShellScriptBin "resolution_fix" ''
    sudo cvt 2560 1080 60
    sudo xrandr --newmode "2560x1080_60.00"  230.00  2560 2720 2992 3424 1080 1083 1093 1120 -hsync +vsync
    sudo xrandr --addmode HDMI-1 2560x1080_60.00
  '';

  resolutionfix2 = pkgs.writeShellScriptBin "resolution_fix2" ''
    sudo xrandr --newmode "2560x1080" 230.37 2560 2728 3000 3440 1080 1081 1084 1118 -HSync +Vsync
    sudo xrandr --addmode HDMI-1 2560x1080
    sudo xrandr --output HDMI-1 --mode 2560x1080
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
    networkmanager.enable = true;
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
    resolutionfix2
  ];
}


