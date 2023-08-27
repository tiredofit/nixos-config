{ inputs, lib, outputs, pkgs, ... }:

{
  environment = {
    systemPackages = [pkgs.git];
  };

  nix = {
    gc = {
      automatic = true;
      dates = "19:00";
      persistent = true;
      options = "--delete-older-than 10d";
    };

    settings = {
      accept-flake-config = true;
      auto-optimise-store = lib.mkDefault true;
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      # show more log lines for failed builds
      log-lines = 30;
      # Free up to 10GiB whenever there is less than 5GB left.
      # this setting is in bytes, so we multiply with 1024 thrice
      min-free = "${toString (5 * 1024 * 1024 * 1024)}";
      max-free = "${toString (10 * 1024 * 1024 * 1024)}";
      max-jobs = "auto";
      trusted-users = [ "root" "@wheel" ];
      warn-dirty = false;
    };

    package = pkgs.nixFlakes;
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = [ "nixpkgs=${inputs.nixpkgs.outPath}" ];
  };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowBroken = false;
      allowUnfree = true;
      allowUnsupportedSystem = true;
      permittedInsecurePackages = [
      ];
    };
  };

  system = {
    activationScripts.report-changes = ''
      PATH=$PATH:${lib.makeBinPath [ pkgs.nvd pkgs.nix ]}
      nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)
    '';
    autoUpgrade.enable = false;
    stateVersion = lib.mkDefault "23.11";
  };
}

