{config, lib, pkgs, ...}:

let
  cfg = config.host.application.tmux;
in
  with lib;
{
  options = {
    host.application.tmux = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables terminal multiplexer";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      tmux
    ];
  };
}