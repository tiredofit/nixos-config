{ config, ...}:

{
  imports =
    [
      ./cli/default.nix
      ./locale.nix
      ./nix.nix
      ./users_groups.nix
    ];

  security.sudo.wheelNeedsPassword = false ;
  time.timeZone = "America/Vancouver";
}
