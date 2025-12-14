{ config, pkgs, lib, _module, ... }:
let
  systemPkgs = _module.args.systemPkgs or (throw "patch-withNspawn.nix requires _module.args.systemPkgs to be set");
in
{
  config = {
    # Ensure the `systemd.package` used by NixOS modules exposes
    # `withNspawn`. Some stable nixpkgs revisions don't provide this
    # attribute which causes evaluation errors in the upstream
    # `nixos/modules/system/boot/systemd.nix` when it checks
    # `cfg.package.withNspawn`.
    systemd.package = systemPkgs.systemd // { withNspawn = true; };
  };
}
