{ config, pkgs, ... }:

{
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
}
