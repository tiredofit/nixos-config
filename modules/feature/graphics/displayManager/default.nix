{config, lib, pkgs, ...}:
let
  cfg = config.host.feature.graphics.displayManager;
in
  with lib;
{
  imports = [
    ./cage.nix
    ./gdm.nix
    ./greetd.nix
    ./lightdm.nix
    ./openbox.nix
    ./sddm.nix
  ];

  options = {
    host.feature.graphics.displayManager = {
      manager = mkOption {
        type = types.enum ["cage" "greetd" "gdm" "lightdm" "sddm" null];
        ## TODO Finish CAGE
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
      };
    };
  };
}
