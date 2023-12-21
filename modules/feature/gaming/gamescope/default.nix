{config, lib, pkgs, ...}:

let
  cfg = config.host.feature.gaming.gamescope;
in
  with lib;
{
  options = {
    host.feature.gaming.gamescope = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "SteamOS session compositing window manager";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gamescope
    ];
  };
}
