{config, lib, ...}:
{

  imports = [
    ./gdm.nix
    ./lightdm.nix
    ./sddm.nix
  ];
}