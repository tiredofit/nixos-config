{ lib, inputs, nixpkgs, disko, hyprland, impermanence, nur, sops-nix, vscode-server, ... }:

let
  pkgs = import nixpkgs {
    config.allowUnfree = true;
  };

  lib = nixpkgs.lib;
in

{
  beef = lib.nixosSystem rec {
    system = "x86_64-linux";

    specialArgs = {
      inherit inputs;
#      nic = "wlp10s0";
#      encrypted = true;
#      gui = true;
#      impermanence = true;
#      display_primary = "DP-2";
#      display_secondary = "DP-3";
#      display_tertiary = "HDMI-1";
    } // inputs;

    modules = [
      ./beef
      nur.nixosModules.nur
      vscode-server.nixosModules.default
    ];

  };

  beer = lib.nixosSystem rec {
    system = "aarch64-linux";
    specialArgs = {
      inherit inputs;
      kioskUsername = "dave";
      kioskURL = "https://beer.tiredofit.ca";
    } // inputs;

    modules = [
      ./beer
    ];
  };

  butcher = lib.nixosSystem rec {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
    } // inputs;

    modules = [
      ./butcher
      nur.nixosModules.nur
    ];
  };

  newbutcher = lib.nixosSystem rec {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
    } // inputs;

    modules = [
      ./newbutcher
      nur.nixosModules.nur
    ];
  };

  soy = lib.nixosSystem rec {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      GUI = true;
    } // inputs;

    modules = [
      ./soy
      nur.nixosModules.nur
      vscode-server.nixosModules.default
    ];
  };
}
