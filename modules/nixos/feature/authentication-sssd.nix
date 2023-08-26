{config, lib, pkgs, ...}:

let
  cfg = config.host.feature.authentication.sssd;
in
  with lib;
{
  options = {
    host.feature.authentication.sssd = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables ability to authenticate against LDAP servers";
      };
    };
  };
  ## TODO Add additional options
  config = mkIf cfg.enable {
    services = {
      sssd = {
        enable = true;
        sshAuthorizedKeysIntegration = true;
        config = ''
        '';
      };
    };
  };
}
