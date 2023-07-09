{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    dmraid
    gptfdisk
  ];
}
