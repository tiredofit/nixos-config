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
    users = {
      defaultUserShell = pkgs.zsh;
    };
  };
}
