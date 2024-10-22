{ config, lib, pkgs, ... }:

let
  cfg = config.host.network.bridge;
  wiredcfg = config.host.network.wired;
in with lib; {
  options = {
    host.network.bridge = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable a bridged network interface";
      };
      name = mkOption {
        type = with types; str;
        default = "br0";
        description = "Name of bridge";
      };
      interfaces = mkOption {
        type = types.listOf types.str;
        default = [ "enp1s0" ];
        description = "List of Interfaces to join to the bridge";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [ ];

    systemd = {
      network = {
        enable = true;
        netdevs = {
          "20-${cfg.name}" = {
            netdevConfig = {
              Kind = "bridge";
              Name = "br0";
              MACAddress = wiredcfg.mac;
            };
          };
        };

        networks = let
          fn = ifnames: o:
            listToAttrs
            (map (ifn: lib.nameValuePair "10-${ifn}" (o ifn)) ifnames);
        in fn cfg.interfaces (ifn: {
          matchConfig.Name = ifn;
          networkConfig.Bridge = cfg.name;
          linkConfig = { RequiredForOnline = "enslaved"; };
        });
      };
    };
  };
}
