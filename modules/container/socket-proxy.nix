{config, lib, pkgs, ...}:

let
  container_name = "socket-proxy2";
  container_description = Enables docker.sock proxy container
  cfg = config.host.container.${name};
  hostname = config.host.network.hostname;
in
  with lib;
{
  options = {
    host.container.${name} = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = container_description ;
      };
    };
  };

  config = mkIf cfg.enable {
    system.activationScripts.docker_${container_name} =
      let
      in ''
        if [ -d /var/local/data/_system/${container_name}/logs ]; then
            mkdir -p /var/local/data/_system/${container_name}/logs
            chattr +C /var/local/data/_system/${container_name}/logs
        fi
      '';

    virtualisation.oci-containers.containers.whoogle = {
      image = "benbusby/whoogle-search";
      ports = [ "0.0.0.0:5000:5000" ];
    };
  };
}