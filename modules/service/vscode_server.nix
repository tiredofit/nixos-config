{config, inputs, lib, pkgs, ...}:

let
  cfg = config.host.service.vscode_server;
in
  with lib;
{
  imports = [
    inputs.vscode-server.nixosModules.default
  ];

  options = {
    host.service.vscode_server = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables useage of Visual Studio Code from remote hosts";
      };
    };
  };

  config = mkIf cfg.enable {
    services = {
      vscode-server.enable = true;
    };

    #host.filesystem.impermanence.directories = lib.mkIf config.host.filesystem.impermanence.enable [
    #  "/var/empty"               # VS Code server throws error on startup without this
    #];
  };
}
