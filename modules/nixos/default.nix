{ config, lib, pkgs, specialArgs, ... }:

let
  inherit (specialArgs) encrypted impermanence gui;
  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isLinux isDarwin;
in
{
  imports =
    [
      ./cli/default.nix
      ./locale.nix
      ./nix.nix
      ./power_management.nix
      ./secrets.nix
      # ./impermanence.nix
      ./users_groups.nix
    ];
    ++ lib.optionals ( impermanence && !encrypted) [
    #  ./impermanence_nocrypt.nix
    #]
    #++ lib.optionals ( impermanence && encrypted) [
      #./impermanence.nix
    #];

  environment.systemPackages = with pkgs; [
    cryptsetup          # open LUKS containers
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
