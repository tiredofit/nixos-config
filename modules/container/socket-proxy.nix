{config, lib, pkgs, ...}:

let
  container_name = "socket-proxy2";
  container_description = "Enables docker.sock proxy container";
  cfg = config.host.container.${container_name};
  hostname = config.host.network.hostname;
  activationScript = "system.activationScripts.docker_${container_name}";
in
  with lib;
{
  options = {
    host.container.${container_name} = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = container_description ;
      };
    };
  };

#    system.activationScripts.docker_${container_name} = ''
  config = mkIf cfg.enable {
    system.activationScripts.docker_socket_proxy = ''
        if [ ! -d /var/local/data/_system/${container_name}/logs ]; then
            mkdir -p /var/local/data/_system/${container_name}/logs
            ${pkgs.e2fsprogs}/bin/chattr +C /var/local/data/_system/${container_name}/logs
        fi
      '';

    systemd.services.docker-nginx = {
      serviceConfig = {
        StandardOutput = "null";
        StandardError = "null";
      };
    };

    virtualisation.oci-containers.backend = "docker";
    virtualisation.oci-containers.containers.nginx = {
      image = "tiredofit/nginx";
      ports = [ "5000:80" ];
      volumes = [
        "/tmp/html:/www/html"
        "/tmp/logs:/www/logs"
      ];
      environment = {
        CONTAINER_NAME = "yeehaw";
        FOO = "bar";
        BAZ = "poo";
      };
      #extraOptions = "--label dave.is.rad=foo";

      autoStart = true;
      log-driver = "local";
      #login = {
      #  registry = "docker.io";
      #};

    };
  };
}