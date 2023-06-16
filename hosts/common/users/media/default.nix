{ pkgs, config, ... }:
let ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
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
}
