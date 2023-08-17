{ config, lib, ... }:
{
  services = {
    fail2ban = {
      enable = true;
    };
  };

  hostoptions.impermanence.directories = lib.mkIf config.hostoptions.impermanence.enable [
    "/var/lib/fail2ban"                # Fail2ban Database
  ];
}
