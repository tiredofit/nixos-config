{ config, lib, pkgs, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
  with lib;
{
  options = {
    host.user.alex = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable Alex";
      };
    };
  };

  config = mkIf config.host.user.alex.enable {
    users.users.alex = {
      isNormalUser = true;
      shell = pkgs.bashInteractive;
      uid = 2323;
      group = "users" ;
      extraGroups = [
        "wheel"
        "video"
        "audio"
      ] ++ ifTheyExist [
        "adbusers"
        "deluge"
        "dialout"
        "docker"
        "git"
        "input"
        "libvirtd"
        "lp"
        "mysql"
        "network"
        "podman"
      ];

      openssh.authorizedKeys.keys = [ (builtins.readFile ./ssh.pub) ];
      #hashedPasswordFile = mkDefault config.sops.secrets.alex-password.path;
      initialPassword = "12345"
    };

    sops.secrets.alex-password = {
      sopsFile = mkDefault ../secrets.yaml;
      neededForUsers = mkDefault true;
    };
  };
}
