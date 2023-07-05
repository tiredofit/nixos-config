{ config, ... }:
{
  services = {
    fail2ban = {
      enable = true;
      extraSettings = {

      };
    };
  };
}
