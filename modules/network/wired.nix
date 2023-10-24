{config, lib, pkgs, ...}:

let
  cfg = config.host.network.wired;
  defaultIP =
  if ((cfg.ip == "0.0.0.0/0") && (cfg.type == "static"))
  then true
  else false;

  defaultGW =
  if ((cfg.gateway == "0.0.0.0") && (cfg.type == "static"))
  then true
  else false;

  defaultMAC =
  if ((cfg.mac == "null") && (cfg.type == "static"))
  then true
  else false;
in
  with lib;
{
  options = {
    host.network.wired = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Manage simple network addressing functions for easier configuration";
      };
      type = mkOption {
        type = with types; enum ["static" "dynamic"];
        default = "static";
        description = "Whether to static of dynamically set IP addresses";
      };
      dns = mkOption {
        type = types.listOf types.str;
        default = [ "1.1.1.1" "1.0.0.1" ];
        description = "DNS resolvers";
      };
      gateway = mkOption {
        type = with types; str;
        default = "0.0.0.0";
        description = "Gateway Address";
      };
      ip = mkOption {
        type = with types; str;
        default = "0.0.0.0/0";
        description = "IPv4 Address with Subnet";
      };
      mac = mkOption {
        type = with types; str;
        default = "*";
        description = "MAC Address to Match";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> !defaultGW;
        message = "[host.network.wired.gateway] Enter in a Gateway address otherwise you will have no routable network access";
      }
      {
        assertion = cfg.enable -> !defaultIP;
        message = "[host.network.wired.ip] Enter in an IP Address otherwise you will have no network access";
      }
      {
        assertion = cfg.enable -> !defaultMAC;
        message = "[host.network.wired.mac] Enter in a MAC Address so that the correct network card is used";
      }
    ];

    networking = {
      useNetworkd = false;
    };

    systemd = {
      network = {
        enable = true;
        networks = {
          "${config.host.network.hostname}" = {
             networkConfig.DHCP = mkIf (cfg.type == "dynamic") "yes";
             matchConfig.MACAddress = cfg.mac ;
             address = mkIf (cfg.type == "static") [
               cfg.ip
             ];
             #dns = mkIf (cfg.type == "static") [ ## TODO FIX THIS
             #  "1.1.1.1"
             #  "1.0.0.1"
             #];
             #dns = mkIf (cfg.type == "static") [
#
             #] ++ cfg.dns ;
             routes = mkIf (cfg.type == "static") [
               { routeConfig.Gateway =  cfg.gateway ; }
             ];
             linkConfig.RequiredForOnline = mkIf (cfg.type == "static") "routable" ;
           };
        };
      };
    };
  };
}