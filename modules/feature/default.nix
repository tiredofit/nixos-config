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
    ./appimage.nix
    ./cross_compilation.nix
    ./home_manager.nix
    ./fonts.nix
    ./s3ql.nix
    ./secrets.nix
    ./security.nix
  ];
}
