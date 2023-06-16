{ config, pkgs, ...}: {

  environment.systemPackages = with pkgs; [
    steam-rom-manager
    steam-run
    steam-tui
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}