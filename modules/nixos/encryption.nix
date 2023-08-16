 {config, lib, pkgs, ...}:

let
  cfg_encrypted = config.hostoptions.encryption;
in
  with lib;
{
  imports =
  [
  ];

  options = {
    hostoptions.encryption = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Encrypt Filesystem";
      };
      encrypted-partition = mkOption {
        type = types.str;
        default = "pool0_0";
        description = "Encrypted LUKS container to mount";
      };
    };
  };

  config = mkIf cfg_encrypted.enable {
    systemPackages =  with pkgs; [
      cryptsetup          # Manipulate LUKS containers
    ];
  };
}
