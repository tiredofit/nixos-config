{config, lib, pkgs, ...}:

let
  cfg = config.host.application.dust;
in
  with lib;
{
  options = {
    host.application.dust = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables graphical disk usage";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      du-dust
    ];
  };
}