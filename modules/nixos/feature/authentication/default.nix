{config, lib, ...}:
with lib;
{
  imports = [
    ./ldap
    ./sssd
  ];
}