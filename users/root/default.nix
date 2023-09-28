{ config, lib, pkgs, ... }:
  with lib;
{
  options = {
    host.user.root = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable root";
      };
    };
  };

  config = mkIf config.host.user.root.enable {
    users.users.root = {
      shell = pkgs.bashInteractive;
      hashedPasswordFile = config.sops.secrets.root-password.path;
      packages = [ pkgs.home-manager ];
    };

    sops.secrets.root-password = {
      sopsFile = ../secrets.yaml;
      neededForUsers = true;
    };
  };
}
