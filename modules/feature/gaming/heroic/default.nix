{config, inputs, lib, pkgs, ...}:

let
  cfg = config.host.feature.gaming.heroic;
in
  with lib;
  with pkgs;
{
  options = {
    host.feature.gaming.heroic = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables heroic gaming support";
      };
      protonGE = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables ProtonGE from nix-gaming should be added";
      };
      extraCompatPackages = mkOption {
        type = with types; listOf package;
        default = [];
        defaultText = literalExpression "[]";
        example = literalExpression ''
          with pkgs; [
            luxtorpeda
            proton-ge
          ]
        '';
        description = mdDoc ''
          Extra packages to be used as compatibility tools for heroic on Linux. Packages will be included
          in the `heroic_EXTRA_COMPAT_TOOLS_PATHS` environmental variable. For more information see
          <https://github.com/ValveSoftware/heroic-for-linux/issues/6310">.
        '';
      };
    };
  };

  config = let
    CompatPackages =
      if cfg.protonGE == true
      then cfg.extraCompatPackages ++ [inputs.nix-gaming.packages.proton-ge]
      else cfg.extraCompatPackages;
    in
      lib.mkIf (cfg.enable) {
        environment.systemPackages = [
          heroic
        ];
      };
}