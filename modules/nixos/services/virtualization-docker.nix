{ config, pkgs, ... }:
{
  environment = {
    etc = {
      "docker/daemon.json" = {
        text = ''
{
  "experimental": true,
  "live-restore": true,
  "shutdown-timeout": 120
}
        '';
        mode = "0600";
      };
    };

    persistence."/persist" = {
      hideMounts = true ;
      directories = [
        "/var/lib/docker"                  # Docker
      ];
    };

    systemPackages = with pkgs; [
      docker-compose
    ];
  };

#  hostoptions.impermanence.directories = [
#    "/var/lib/docker"                  # Docker
#  ];

  system.activationScripts.create_docker_networks = let
    dockerBin = "${pkgs.docker}/bin/docker";
  in ''
     ${dockerBin} network inspect proxy > /dev/null || ${dockerBin} network create proxy --subnet 172.19.0.0/18
     ${dockerBin} network inspect services >/dev/null || ${dockerBin} network create services --subnet 172.19.128.0/18
     ${dockerBin} network inspect socket-proxy >/dev/null || ${dockerBin} network create socket-proxy --subnet 172.19.192.0/18
   '';

  users.groups = {
    docker = {};
  };

  virtualisation = {
     docker = {
       enable = true;
       enableOnBoot = false ;
       logDriver = "local";
       storageDriver = "btrfs";
     };
 };
}
