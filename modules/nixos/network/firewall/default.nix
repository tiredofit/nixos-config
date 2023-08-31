{lib, ...}:

with lib;
{
  imports = [
    ./fail2ban.nix
    ./opensnitch.nix
  ];
}
