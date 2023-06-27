{ config, pkgs, ... }:

{
  imports =
      ./hardware-configuration.nix
      ../../modules/nixos/default.nix
      ../../modules/nixos/services/openssh.nix
      ../../modules/nixos/gui/wayland-kiosk.nix
    ];

  boot = {
    loader = {
      generic-ext-linux-compatible.enable = true;
      grub.enable = true;
    }
  }

  networking.hostName = "beer";
  Pick only one of the below networking options.
  networking.networkmanager.enable = true;
  time.timeZone = "America/Vancouver";
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "23.05";
}

