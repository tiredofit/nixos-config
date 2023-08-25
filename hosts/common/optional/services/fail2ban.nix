{ config, lib, ... }:
{
  services = {
    fail2ban = {
      enable = true;
    };
  };

  host.feature.impermanence.directories = lib.mkIf config.host.feature.impermanence.enable [
    "/var/lib/fail2ban"                # Fail2ban Database
  ];
}
