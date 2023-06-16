{ config, lib, pkgs, ... }:
{
    environment.systemPackages = [ pkgs.qbittorrent-nox ];

#    networking.firewall = {
#      allowedTCPPorts = [ 6990 8112 ];
#      allowedUDPPorts = [ 6990 8112 ];
#    };

    systemd.services.qbittorrent = {
      after = [ "network.target" ];
      description = "qBittorrent Daemon";
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.qbittorrent-nox ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.qbittorrent-nox}/bin/qbittorrent-nox \
            --profile=/var/local/data/qbittorrent \
            --webui-port=8000
        '';
        # To prevent "Quit & shutdown daemon" from working; we want systemd to
        # manage it!
        Restart = "on-success";
        User = "qbittorrent" ;
        Group = "qbittorrent" ;
        UMask = "0002";
        # LimitNOFILE = cfg.openFilesLimit;
      };
    };

    users.users = {
      qbittorrent = {
        group = "qbittorrent" ;
        home = "/var/local/data/qbittorrent" ;
        createHome = true;
        isSystemUser = true;
        description = "qBittorrent Daemon user";
      };
    };

    users.groups = {
     "qbittorrent" = {
        gid = null;
      };
    };

   networking.firewall.enable = false;
}
