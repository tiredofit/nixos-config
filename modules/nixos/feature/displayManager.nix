{config, lib, pkgs, ...}:
with lib;
{
  imports = [
    ../../../hosts/common/fonts.nix
    ./displayManager/x.nix
    ./displayManager/wayland.nix
  ];

  options = {
    host.feature.displayManager = {
      server = mkOption {
        type = types.str;
        default = null;
        description = "Type of displayManager: x or wayland";
      };
    };
  };
}