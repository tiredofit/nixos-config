{ config, ... }:
{
  services = {
    fail2ban = {
      enable = true;
      extraSettings = {

      };
    };
  };

  environment.persistence."/persist" = {
    hideMounts = true ;
    directories = [
      "/var/lib/fail2ban"                # Fail2ban Database
    ];
  };
}
