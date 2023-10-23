{config, lib, pkgs, ...}:

let
  cfg = config.host.application.nvd;
in
  with lib;
{
  options = {
    host.application.nvd = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables Nix version differences";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      nvd
    ];
  };
}