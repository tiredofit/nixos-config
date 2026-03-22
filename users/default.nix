{lib, pkgs, ...}:

with lib;
{
  imports = [
    ./dave
    ./ireen
    ./root
    ./tttttt
  ];

  config = {
    environment.shells = with pkgs; [
      bashInteractive
      zsh
    ];
    system = {
      userActivationScripts = {
        zshrc = "touch .zshrc";
      };
    };
    users = {
      defaultUserShell = pkgs.zsh;
    };
  };
}
