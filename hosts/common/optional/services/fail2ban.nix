{ config, lib, ... }:
{
  services = {
    fail2ban = {
      enable = true;
    };
  };

  host.filesystem.impermanence.directories = lib.mkIf config.host.filesystem.impermanence.enable [
    "/var/lib/fail2ban"                # Fail2ban Database
  ];
}
