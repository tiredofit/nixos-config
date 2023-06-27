{ pkgs, config, lib, ...}:

{
  nix = {
    autoOptimiseStore = true ;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    gc = {
      automatic = true;
      dates = "19:00";
      persistent = true;
      options = "--delete-older-than 60d";
    };
    optimize = {
      automatic = true;
    }

    package = pkgs.nixFlakes;
  };

  nixpkgs.config.allowUnfree = true ; # Allow Non Free packages

  system.activationScripts.report-changes = ''
    PATH=$PATH:${lib.makeBinPath [ pkgs.nvd pkgs.nix ]}
    nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)
  '';
}
