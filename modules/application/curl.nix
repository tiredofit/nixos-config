{config, lib, pkgs, ...}:

let
  cfg = config.host.application.curl;
in
  with lib;
{
  options = {
    host.application.curl = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables curl";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      curl
    ];
  };
}