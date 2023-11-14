{config, lib, pkgs, ...}:

let
  cfg = config.host.network.vpn.zerotier;

in
  with lib;
{
  options = {
    host.network.vpn.zerotier = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables Zerotier virtual ethernet switch functionality";
      };
      identity = {
        public = {
          default = "null";
          type = with types; str;
          description = "Public Identity";
        };
        private = {
          default = "null";
          type = with types; str;
          description = "Private key of Identity";
        };
      };
      networks = mkOption {
        type = with types; listOf str;
        description = "List of Network IDs to join on startup and back out of on stop";
      };
      port = mkOption {
        default = 9993;
        type = with types; port;
        description = "Network port used by Zerotier";
      };
    };
  };

  config = mkIf cfg.enable {
    services.zerotierone = {
      enable = true;
      port = cfg.port;
    };

    systemd.services.zerotierone = {
      preStart = mkOverride 50 ''
        mkdir -p /var/lib/zerotier-one/networks.d
        chmod 700 /var/lib/zerotier-one
        chown -R root:root /var/lib/zerotier-one
        network_list=$(echo ${toString cfg.networks} | tr ' ' '\n')

        _zt_join_network() {
          echo "Joining $1"
          set -x
          touch /var/lib/zerotier-one/networks.d/"$1".conf
          set +x
        }

        for network in $network_list ; do
            [[ "$network" =~ ^[[:space:]]*# ]] && continue
              if [ -f $network ] ; then
              echo "Reading networks from file"
              while read line; do
                [[ "$line" =~ ^[[:space:]]*# ]] && continue
                  _zt_join_network $(echo $line | ${pkgs.gawk}/bin/awk '{print $1}')
              done < "$network"
            else
                _zt_join_network $network
            fi
        done
        if [ -f /var/run/secrets/zerotier/identity_public ] ; then cat "/var/run/secrets/zerotier/identity_public" > /var/lib/zerotier-one/identity.public ; fi
        if [ -f /var/run/secrets/zerotier/identity_private ] ; then cat "/var/run/secrets/zerotier/identity_private" > /var/lib/zerotier-one/identity.secret  ; fi

      '';
      postStop = ''
        _zt_leave_network() {
          echo "Leaving $1"
          rm -rf /var/lib/zerotier-one/networks.d/"$1".conf
        }

        network_list=$(echo ${toString cfg.networks} | tr ' ' '\n')
        for network in $network_list ; do
            if [ -f $network ] ; then
              echo "Reading networks from file"
              while read line; do
                [[ "$line" =~ ^[[:space:]]*# ]] && continue
                  _zt_leave_network $(echo $line | ${pkgs.gawk}/bin/awk '{print $1}')
              done < "$network"
            else
                _zt_leave_network $network
            fi
        done

        if [ -f /var/run/secrets/zerotier/identity_public ] ; then rm -rf "/var/lib/zerotier-one/identity.public" ; fi
        if [ -f /var/run/secrets/zerotier/identity_private ] ; then rm -rf "/var/lib/zerotier-one/identity.secret" ; fi
      '';
    };

    sops.secrets = {
      ## Only read these secrets if the secret exists
      "zerotier/networks" = mkIf (builtins.pathExists ../../../hosts/${config.host.network.hostname}/secrets/zerotier/networks.yaml)  {
        sopsFile = ../../../hosts/${config.host.network.hostname}/secrets/zerotier/networks.yaml;
        restartUnits = [ "zerotierone.service" ];
      };
      "zerotier/identity_public" = mkIf (builtins.pathExists ../../../hosts/${config.host.network.hostname}/secrets/zerotier/identity.yaml)  {
        sopsFile = ../../../hosts/${config.host.network.hostname}/secrets/zerotier/identity.yaml;
        restartUnits = [ "zerotierone.service" ];
      };
      "zerotier/identity_private" = mkIf (builtins.pathExists ../../../hosts/${config.host.network.hostname}/secrets/zerotier/identity.yaml)  {
        sopsFile = ../../../hosts/${config.host.network.hostname}/secrets/zerotier/identity.yaml;
        restartUnits = [ "zerotierone.service" ];
      };
    };
    #host.filesystem.impermanence.directories = lib.mkIf config.host.filesystem.impermanence.enable [
    #  "/var/cache/zerotier-one"
    #];
  };
}