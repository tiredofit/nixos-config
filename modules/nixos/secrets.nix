{ config, lib, pkgs, sops-nix, ... }:

let
  isEd25519 = k: k.type == "ed25519";
  getKeyPath = k: k.path;
  keys = builtins.filter isEd25519 config.services.openssh.hostKeys;
in
{
  imports = [
    sops-nix.nixosModules.sops
  ];

  environment.systemPackages = with pkgs; [
    age
    gnupg
    pinentry.out
    ssh-to-age
    ssh-to-pgp
    sops
  ];

  sops = {
    age.sshKeyPaths = map getKeyPath keys;
  };
}
