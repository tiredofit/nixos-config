{ config, ... }:
{
  services.printing.enable = true;

  hostoptions.impermanence.directories = [
    "/var/lib/cups"          # CUPS
  ];
}