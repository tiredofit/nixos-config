{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    s3ql
  ]

}