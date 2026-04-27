{ config, lib, pkgs, ... }:
{
  services = {
    sonarr = {
      enable = true;
      dataDir = "/var/local/data/sonarr";
    };
  };
}
