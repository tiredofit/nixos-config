{ config, ... }:
{
  services.printing.enable = true;

  environment.persistence."/persist" = {
    hideMounts = true ;
    directories = [
      "/var/lib/cups"          # CUPS
    ];
  };
}
