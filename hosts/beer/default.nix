{ config, pkgs, ... }:

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
  };

  networking = {
    hostName = "beer";
    networkmanager.enable = true;
  };

  nix.settings.trusted-users = [ "root" "@wheel" "dave" ];
  system.stateVersion = "23.05";
}


