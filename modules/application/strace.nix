{config, lib, pkgs, ...}:

let
  cfg = config.host.application.strace;
in
  with lib;
{
  options = {
    host.application.strace = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables debugging tools";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      strace
    ];
  };
}