{config, lib, pkgs, ...}:

let
  cfg = config.host.application.fzf;
in
  with lib;
{
  options = {
    host.application.fzf = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables Fuzzy Finder";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fzf
    ];
  };
}