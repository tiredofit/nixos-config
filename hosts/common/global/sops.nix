{ config, inputs, lib, outputs, pkgs, ... }:
let
  inherit (config.networking) hostName;
  hostsecrets = ../../${hostName}/secrets/secrets.yaml;
  isEd25519 = k: k.type == "ed25519";
  getKeyPath = k: k.path;
  keys = builtins.filter isEd25519 config.services.openssh.hostKeys;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
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
    secrets = {
      ${hostName} = {
        sopsFile = hostsecrets;
      };
      common = {
        sopsFile = ../secrets/secrets.yaml;
      };
    };
  };
}
