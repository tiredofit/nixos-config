{config, lib, pkgs, ...}:

let
  cfg = config.host.service.fluent-bit;
in
  with lib;
{
  options = {
    host.service.fluent-bit = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables daemon for shipping logs and metrics";
      };
    };
  };
  ## TODO Add more options relating to port and configuration
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fluent-bit
    ];
  };
}
