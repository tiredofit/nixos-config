{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    eternal-terminal
  ];
}