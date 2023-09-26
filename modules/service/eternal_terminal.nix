{config, lib, pkgs, ...}:

let
  cfg = config.host.service.eternalterminal;
in
  with lib;
{
  options = {
    host.service.eternalterminal = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables daemon for long lasting session persistence";
      };
    };
  };
  ## TODO Add more options relating to port and configuration
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      eternal-terminal
    ];
  };
}
