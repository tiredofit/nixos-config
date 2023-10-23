{config, lib, pkgs, ...}:

let
  cfg = config.host.application.links;
in
  with lib;
{
  options = {
    host.application.links = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables links";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      links2
    ];
  };
}