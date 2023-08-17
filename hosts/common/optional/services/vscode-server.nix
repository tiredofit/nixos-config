{ lib, config, pkgs, ... }:

{
  services = {
    vscode-server.enable = true;
  };

  hostoptions.impermanence.directories = lib.mkIf config.hostoptions.impermanence.enable [
    "/var/empty"               # VS Code server throws error on startup without this
  ];
}
