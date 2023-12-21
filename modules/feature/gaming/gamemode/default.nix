{config, lib, pkgs, ...}:

let
  cfg = config.host.feature.gaming.gamemode;
in
  with lib;
{
  options = {
    host.feature.gaming.gamemode = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Optimise Linux system performance on demand";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gamemode
    ];
  };
}
