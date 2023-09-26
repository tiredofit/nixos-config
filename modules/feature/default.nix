{lib, ...}:

with lib;
{
  imports = [
    ./authentication
    ./boot
    ./gaming
    ./graphics
    ./powermanagement
    ./virtualization
    ./cross_compilation.nix
    ./fonts.nix
    ./s3ql.nix
    ./secrets.nix
    ./security.nix
  ];
}
