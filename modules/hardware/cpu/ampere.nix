{ config, lib, pkgs, ... }:
let
  device = config.host.hardware ;
in
  with lib;
{
  config = mkIf (device.cpu == "ampere") {
    nixpkgs.hostPlatform = "aarch64-linux";
  };
}
