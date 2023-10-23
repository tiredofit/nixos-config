{config, lib, pkgs, ...}:

let
  cfg = config.host.application.ncdu;
in
  with lib;
{
  options = {
    host.application.ncdu = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables ncurses graphical disk usage";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ncdu
    ];
  };
}