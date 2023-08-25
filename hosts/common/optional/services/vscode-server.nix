{ config, lib, pkgs, ... }:

{
  services = {
    vscode-server.enable = true;
  };

  host.filesystem.impermanence.directories = lib.mkIf config.host.filesystem.impermanence.enable [
    "/var/empty"               # VS Code server throws error on startup without this
  ];
}
