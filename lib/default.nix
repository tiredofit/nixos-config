{ inputs, nixpkgs, inputs,  ...}:
let
  inherit (nixpkgs) lib;

  services = import ./services.nix {inherit lib;};
  validators = import ./validators.nix {inherit lib;};
  helpers = import ./helpers.nix {inherit lib;};
in
  nixpkgs.lib.extend (_: _: services // validators // helpers)