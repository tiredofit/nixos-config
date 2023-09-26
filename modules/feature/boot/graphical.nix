{config, lib, pkgs, ...}:

let
  cfg = config.host.feature.boot.graphical;
in
  with lib;
{
  options = {
    host.feature.boot.graphical = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables graphical boot screen";
      };
    };
  };

  config = mkIf cfg.enable {
    boot = {
      plymouth = {
        enable = true ;
        theme = "lone" ;
        themePackages = [(pkgs.adi1090x-plymouth-themes.override {selected_themes = ["lone"];})];
      };
    };

    # make plymouth work with sleep
    #powerManagement = {
    #  powerDownCommands = ''
    #    ${pkgs.plymouth}/bin/plymouth --show-splash
    #  '';
    #  resumeCommands = ''
    #    ${pkgs.plymouth}/bin/plymouth --quit
    #  '';
    #};
  };
}
