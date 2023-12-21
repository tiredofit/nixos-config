{config, inputs, lib, pkgs, ...}:

let
  cfg = config.host.feature.gaming.steam;
in
  with lib;
  with pkgs;
{
  options = {
    host.feature.gaming.steam = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables Steam gaming support";
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
          Extra packages to be used as compatibility tools for Steam on Linux. Packages will be included
          in the `STEAM_EXTRA_COMPAT_TOOLS_PATHS` environmental variable. For more information see
          <https://github.com/ValveSoftware/steam-for-linux/issues/6310">.
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
          steam-rom-manager
          steam-run
          steam-tui
        ];

        programs.steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
        };
      };
}