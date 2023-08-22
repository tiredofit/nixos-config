{ pkgs, config, ... }:
{
  users.users.root = {
    shell = pkgs.bashInteractive;
    passwordFile = config.sops.secrets.root-password.path;
    packages = [ pkgs.home-manager ];
  };

  sops.secrets.root-password = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };
}
