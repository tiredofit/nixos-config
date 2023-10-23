{config, lib, pkgs, ...}:

let
  cfg = config.host.application.less;
in
  with lib;
{
  options = {
    host.application.less = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables less pager";
      };
    };
  };

  config = mkIf cfg.enable {
    programs = {
      less = {
        enable = true;
        commands = {
           s = "back-line";
           t = "forw-line";
         };
       };
      bash.shellAliases = {
        "more" = "less"; # pager
      };
    };
  };
}