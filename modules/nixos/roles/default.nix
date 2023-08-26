{config, lib, pkgs, ...}:
with lib;
{
  options = {
    host.role = mkOption {
      type = types.str;
      default = "none";
      description = "Role of Host: kiosk";
    };
  };
}
