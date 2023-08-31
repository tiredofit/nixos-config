{lib, ...}:

with lib;
{
  imports = [
    ./bluetooth.nix
    ./cpu.nix
    ./gpu.nix
    ./monitors.nix
    ./printing.nix
    ./raid.nix
    ./sound.nix
    ./touchpad.nix
    ./webcam.nix
    ./wireless.nix
    ./yubikey.nix
  ];
}
