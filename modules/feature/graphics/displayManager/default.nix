{config, lib, pkgs, ...}:
let
  cfg = config.host.feature.graphics.displayManager;
in
  with lib;
{
  imports = [
    ./gdm.nix
    ./greetd.nix
    ./lightdm.nix
    ./sddm.nix
  ];

  options = {
    host.feature.graphics.displayManager = {
      autoLogin = {
        enable = mkOption {
          default = false;
          type = with types; bool;
          description = "Automatically log a user into a session";
        };
        user = mkOption {
          type = with types; str;
          description = "User to auto login";
        };
      };
      manager = mkOption {
        type = types.enum ["greetd" "gdm" "lightdm" "sddm" null];
        default = "lightdm";
        description = "Display Manager to use";
      };
      session = mkOption {
        type = types.listOf types.attrs;
        default = [];
        description = "Sessions that should be available to access via displayManager";
      };
    };
  };

  config = mkIf ((config.host.feature.graphics.enable)) {
    host.feature.graphics.displayManager.session = mkIf (config.host.feature.home-manager.enable) [
        {
          name = "home-manager";
          start = ''
              ${pkgs.runtimeShell} $HOME/.hm-xsession &
              waitPID=$!
          '';
        }
      ];

    services = {
      xserver = {
        desktopManager = {
          session = [ ] ++ config.host.feature.graphics.displayManager.session;
        };
        displayManager = mkIf (cfg.autoLogin.enable) {
          autoLogin = {
            enable = mkDefault true;
            user = cfg.autoLogin.user;
          };
        };
      };
    };
  };
}
