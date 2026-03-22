{ config, lib, pkgs, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
  with lib;
{
  options = {
    host.user.dave = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable Dave";
      };
    };
  };

  config = mkIf config.host.user.dave.enable {
    users.users.dave = {
      isNormalUser = true;
    shell =
      if config.host.application.zsh.enable then pkgs.zsh
      else if config.host.application.bash.enable then pkgs.bashInteractive
      else pkgs.bashInteractive;
      uid = 2323;
      group = "users" ;
      extraGroups = [
        "wheel"
        "video"
        "audio"
      ] ++ ifTheyExist [
        "adbusers"
        "dialout"
        "docker"
        "git"
        "input"
        "libvirtd"
        "lp"
        "network"
        "networkmanager"
        "podman"
      ];

      openssh.authorizedKeys.keys = [ (builtins.readFile ./ssh.pub) ];
      hashedPasswordFile = mkDefault config.sops.secrets.dave-password.path;
    };

    sops.secrets.dave-password = {
      sopsFile = mkDefault ../secrets.yaml;
      neededForUsers = mkDefault true;
    };
  };
}
