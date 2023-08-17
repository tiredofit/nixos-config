{ inputs, lib, pkgs, ... }:
#{ config, lib, pkgs, ...}:

{
  nix = {
    gc = {
      automatic = true;
      dates = "19:00";
      persistent = true;
      options = "--delete-older-than 10d";
    };

    settings = {
      auto-optimise-store = lib.mkDefault true;
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      trusted-users = [ "root" "@wheel" ];
      warn-dirty = false;
    };

    package = pkgs.nixFlakes;
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = [ "nixpkgs=${inputs.nixpkgs.outPath}" ];
  };

  nixpkgs.config.allowUnfree = true ; # Allow Non Free packages

  system.activationScripts.report-changes = ''
    PATH=$PATH:${lib.makeBinPath [ pkgs.nvd pkgs.nix ]}
    nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)
  '';
}
