{config, lib, pkgs, ...}:

let
  defaultDomain =
  if (config.host.network.domain == "null")
  then true
  else false;
in
  with lib;
{
  options = {
    host.network.domain = mkOption {
      type = with types; str;
      default = "null";
      description = "Domain name of system";
    };
  };

  config = {
    assertions = [
      {
        assertion = !defaultDomain;
        message = "[host.network.domain] Enter a domain name to add network uniqueness";
      }
    ];

    networking = {
      domain = config.host.network.domain;
    };
  };
}