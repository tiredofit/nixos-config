{ lib, config, pkgs, ... }:

{
  services = {
    vscode-server.enable = true;
  };

  host.feature.impermanence.directories = lib.mkIf config.host.feature.impermanence.enable [
    "/var/empty"               # VS Code server throws error on startup without this
  ];
}
