{config, lib, pkgs, ...}:

let
  cfg_traefik = config.host.container.traefik;
  cfg_tcc = config.host.container.traefik_cloudflare_companion;
in
  with lib;
{
  options = {
    host.container = {
      traefik = {
        enable = mkOption {
          default = false;
          type = with types; bool;
          description = "Enables Traefik Reverse Proxy container";
        };
      };
      traefik_cloudflare_companion = {
        enable = mkOption {
          default = false;
          type = with types; bool;
          description = "Enables Traefik Cloudflare Companion container";
        };
      };
    };
  };

  config = {
  };
}