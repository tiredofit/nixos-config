{config, lib, pkgs, ...}:

let
  cfg = config.host.feature.development.crosscompilation;
in
  with lib;
{
  options = {
    host.feature.development.crosscompilation = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables cross compilation of nix builds";
      };
      platform = mkOption {
        type = types.str;
        default = "aarch64-linux";
        description = "Platforms to cross compile when building";
      };
    };
  };

  config = mkIf cfg.enable {
    boot = {
      binfmt = {
        emulatedSystems = [ cfg.platform ];
      };
    };
  };
}
