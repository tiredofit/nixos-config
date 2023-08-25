 {config, lib, pkgs, ...}:

let
  cfg = config.host.filesystem.encryption;
in
  with lib;
{
  options = {
    host.filesystem.encryption = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Encrypt Filesystem using LUKS";
      };
      encrypted-partition = mkOption {
        type = types.str;
        default = "pool0_0";
        description = "Encrypted LUKS container to mount";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages =  with pkgs; [
      cryptsetup          # Manipulate LUKS containers
    ];
  };
}
