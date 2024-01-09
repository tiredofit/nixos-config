{ config, inputs, outputs, lib, pkgs, ... }:
let
  cfg = config.host.feature.home-manager;
in
  with lib;
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  options = {
    host.feature.home-manager = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable Home manager to provide isolated home configurations per user";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      home-manager
    ];

    home-manager.extraSpecialArgs = { inherit inputs outputs; };
  };
}
