{ config, pkgs, ...}:

{
  imports =
    [
      ./cli/default.nix
      ./locale.nix
      ./nix.nix
      ./secrets.nix
      ./users_groups.nix
    ];

  environment.systemPackages = with pkgs; [

  ]
  ++ (lib.optionals pkgs.stdenv.isLinux [
    e2fsprogs
  ]);

  security.sudo.wheelNeedsPassword = false ;
  time.timeZone = "America/Vancouver";
}
