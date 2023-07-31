{ config, lib, pkgs, ... }:
{
  services = {
    radarr = {
      enable = true;
      dataDir = "/var/local/data/sonarr";
    };
  };
}
