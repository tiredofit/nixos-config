{ config, pkgs, lib, ... }:
{
  config = {
    # Ensure the `systemd.package` used by NixOS modules exposes
    # `withNspawn`. Use the `pkgs` argument provided to modules (which
    # in our `mkSystem` call is set to the already-imported `systemPkgs`).
    systemd.package = pkgs.systemd // { withNspawn = true; };
  };
}
