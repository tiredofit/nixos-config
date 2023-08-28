{lib, ...}:

with lib;
{
  imports = [
    ./desktop.nix
    ./hybrid.nix
    ./kiosk.nix
    ./laptop.nix
    ./hybrid.nix
    ./lite.nix
    ./vm.nix
  ];

  options = {
    host.role = mkOption {
      type = types.enum ["laptop" "desktop" "server" "kiosk" "hybrid" "lite" "vm"];
    };
  };
}
