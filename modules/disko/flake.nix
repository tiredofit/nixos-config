{
  inputs.nixpkgs.url = github:NixOS/nixpkgs;
  inputs.disko.url = github:nix-community/disko;
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  outputs = { self, nixpkgs, disko, ... }@attrs: {
    #-----------------------------------------------------------
    # The following line names the configuration as hetzner-cloud
    # This name will be referenced when nixos-remote is run
    #-----------------------------------------------------------
    nixosConfigurations.test = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ({modulesPath, ... }: {
          imports = [
            (modulesPath + "/installer/scan/not-detected.nix")
            (modulesPath + "/profiles/qemu-guest.nix")
            disko.nixosModules.disko
            ./disko.nix
          ];
          #disko.devices = import ./disko.nix {
          #  lib = nixpkgs.lib;
          #};
          boot.loader.grub = {
            efiSupport = true;
            efiInstallAsRemovable = true;
            device = "nodev";
            enableCryptodisk = false;
            useOSProber = false;
          };


          services.openssh.enable = true;
          #-------------------------------------------------------
          # Change the line below replacing <insert your key here>
          # with your own ssh public key
          #-------------------------------------------------------
          users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAtKh1vr6m9j0y9T7sf928FcacPbIYP9DHzCv2hQIVPS" ];
        })
      ];
    };
  };
}
