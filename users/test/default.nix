{ config, lib, pkgs, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
  with lib;
{
  options = {
    host.user.test = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable Test";
      };
    };
  };

  config = mkIf config.host.user.test.enable {
    users.users.test = {
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
        "lp"
        "mysql"
        "network"
        "podman"
      ];

      openssh.authorizedKeys.keys = [ (builtins.readFile ./ssh.pub) ];
      hashedPassword = "$y$j9T$4m8oNAfLIiJiroWqbEKuO.$CPYvjpOgufbwUrfFemD9XrXfc7SqbAj1MsD1Nn6lKU7";
      packages = [ pkgs.home-manager ];
    };
  };
}
