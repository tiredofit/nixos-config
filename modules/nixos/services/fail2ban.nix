{ config, ... }:
{
  services = {
    fail2ban = {
      enable = true;
      extraSettings = {

      };
    };
  };

  hostoptions.impermanence.directories = [
    "/var/lib/fail2ban"                # Fail2ban Database
  ];
}
