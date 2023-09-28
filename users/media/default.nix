{ config, lib, pkgs, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
  with lib;
{
  options = {
    host.user.media = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable MEdia";
      };
    };
  };

  config = mkIf config.host.user.media.enable {
    users.users.media = {
      isNormalUser = true;
      shell = pkgs.bashInteractive;
      uid = 7777;
      group = "users" ;
      extraGroups = [
        "wheel"
        "video"
        "audio"
      ] ++ ifTheyExist [
        "adbusers"
        "deluge"
        "docker"
        "git"
        "input"
        "libvirtd"
        "mysql"
        "network"
        "podman"
      ];

      openssh.authorizedKeys.keys = [ (builtins.readFile ./ssh.pub) ];
      passwordFile = config.sops.secrets.media-password.path;
      packages = [ pkgs.home-manager ];
    };

    sops.secrets.media-password = {
      sopsFile = ../secrets.yaml;
      neededForUsers = true;
    };
  };
}
