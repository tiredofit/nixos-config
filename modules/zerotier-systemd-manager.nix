{ config, lib, pkgs, ... }:

let
  cfg = config.host.service.zerotier-systemd-manager;
in
  with lib;
{
  options = {
    host.service.zerotier-systemd-manager = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Zerotier DNS Update Service";
      };
      service.enable = mkOption {
        default = true;
        type = with types; bool;
        description = "Auto start on server start";
      };
      package = mkOption {
        type = with types; package;
        description = "Package to use for Managing Zerotier DNS";
        example = "pkgs.zerotier-systemd-manager";
        default = pkgs.zerotier-systemd-manager;
      };
    };
  };


  config = lib.mkIf cfg.enable {
    #assertions = [ {
    #  assertion = config.systemd.network.enable;
    #  message = ''
    #    This module relies on systemd-networkd to manage DNS records per iterface,
    #    please enable it with
    #
    #    systemd.network.enable = true.
    #
    #    In case you use NetworkManager, you might also need
    #
    #    systemd.network.wait-online.enable = false;
    #
    #    See more info on how to enable systemd-networkd in https://nixos.wiki/wiki/Systemd-networkd
    #  '';
    #} ];

    environment.systemPackages = with pkgs; [
      zerotier-systemd-manager
    ];

    systemd = {
      services.zerotier-systemd-manager-dns-update = mkIf cfg.service.enable {
        description = "Update zerotier per-interface DNS settings";
        requires = [ "zerotierone.service" ];
        after = [ "zerotierone.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${cfg.package}/bin/zerotier-systemd-manager";
        };
      };
      timers.zerotier-systemd-manager-dns-update = {
        description = "Update zerotier per-interface DNS settings";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnStartupSec = "1min";
          OnUnitInactiveSec = "1min";
        };
        unitConfig = {
          Description = "Update zerotier per-interface DNS settings";
        };
      };
    };
  };
}
