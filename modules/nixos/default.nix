{ config, lib, pkgs, specialArgs, ... }:

let
  inherit (specialArgs) gui;
  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isLinux isDarwin;
in
{
  imports =
    [
      ./cli/default.nix
      ./encryption.nix
      ./impermanence.nix
      ./locale.nix
      ./nix.nix
      ./power_management.nix
      ./secrets.nix
      ./users_groups.nix
    ];

  environment.systemPackages = with pkgs; [
    e2fsprogs           #
    gptfdisk            # partitioning
    usbutils            # tools for working with usb devices
  ]
  ++ (lib.optionals pkgs.stdenv.isLinux [
    acpi
  ]);

  security.sudo.wheelNeedsPassword = false ;
  time.timeZone = "America/Vancouver";
}
