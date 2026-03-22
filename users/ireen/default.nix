{ config, lib, pkgs, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
  with lib;
{
  options = {
    host.user.ireen = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable Ireen";
      };
    };
  };

  config = mkIf config.host.user.ireen.enable {
    users.users.ireen = {
      isNormalUser = true;
      shell =
        if config.host.application.zsh.enable then pkgs.zsh
        else if config.host.application.bash.enable then pkgs.bashInteractive
        else pkgs.bashInteractive;
      uid = 4242;
      group = "users" ;
      extraGroups = [
        "audio"
        "video"
        "wheel"
      ] ++ ifTheyExist [
        "adbusers"
        "input"
        "lp"
        "network"
        "networkmanager"
      ];

      openssh.authorizedKeys.keys = [ (builtins.readFile ./ssh.pub) ];
      hashedPasswordFile = config.sops.secrets.ireen-password.path;
    };

    sops.secrets.ireen-password = {
      sopsFile = ../secrets.yaml;
      neededForUsers = true;
    };
  };
}
