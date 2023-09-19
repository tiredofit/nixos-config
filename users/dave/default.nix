{ pkgs, config, ... }:
let ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.mutableUsers = false;
  users.users.dave = {
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
      "docker"
      "git"
      "input"
      "libvirtd"
      "mysql"
      "network"
      "podman"
    ];

    openssh.authorizedKeys.keys = [ (builtins.readFile ./ssh.pub) ];
    hashedPasswordFile = config.sops.secrets.dave-password.path;
    packages = [ pkgs.home-manager ];
  };

  sops.secrets.dave-password = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };
}
