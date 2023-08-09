{ config, pkgs, ... }:

{
  services = {
    vscode-server.enable = true;
  };

  hostoptions.impermanence.directories = [
    "/var/empty"               # VS Code server throws error on startup without this
  ];
}
