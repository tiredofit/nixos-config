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
        type = types.enum ["x" "wayland"];
        default = null;
        description = "Type of displayManager";
      };
    };
  };
}