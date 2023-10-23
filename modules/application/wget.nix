{config, lib, pkgs, ...}:

let
  cfg = config.host.application.wget;
in
  with lib;
{
  options = {
    host.application.wget = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables web downloader";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wget
    ];
  };
}