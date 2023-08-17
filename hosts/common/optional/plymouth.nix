{ config, pkgs, ... }:
{
  boot = {
    plymouth = {
      enable = true ;
      theme = "lone" ;
       themePackages = [(pkgs.adi1090x-plymouth-themes.override {selected_themes = ["lone"];})];
    };
  };
}
