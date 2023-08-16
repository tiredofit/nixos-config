{ config, lib, pkgs, ...}:

{
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    gc = {
      automatic = true;
      dates = "19:00";
      persistent = true;
      options = "--delete-older-than 60d";
    };

    package = pkgs.nixFlakes;
    settings = {
      auto-optimise-store = true;
    };
  };

  nixpkgs.config.allowUnfree = true ; # Allow Non Free packages

  system.activationScripts.report-changes = ''
    PATH=$PATH:${lib.makeBinPath [ pkgs.nvd pkgs.nix ]}
    nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)
  '';
}
