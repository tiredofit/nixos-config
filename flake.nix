{
  description = "Tired of I.T! NixOS configuration";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    nur.url = "github:nix-community/NUR";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs = inputs@{
    self,
    nixpkgs,
    impermanence,
    nur,
    sops-nix,
    vscode-server,
    ...
  }: {

   nixosConfigurations = {
      beef = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          pkgs-stable = import inputs.nixpkgs {
            system = system;
            config.allowUnfree = true;
          };
          GUI = true;
        } // inputs;

        modules = [
          ./hosts/beef
          nur.nixosModules.nur
#          sops-nix.nixosModules.sops
          vscode-server.nixosModules.default
        ];
      };

      beer = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        specialArgs = {
          pkgs = import inputs.nixpkgs {
            system = system;
            config.allowUnfree = true;
          };
          kioskUsername = "dave";
          kioskURL = "https://beer.tiredofit.ca";
        } // inputs;

        modules = [
          ./hosts/beer
        ];
      };

      butcher = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          pkgs = import inputs.nixpkgs {
            system = system;
            config.allowUnfree = true;
          };
        } // inputs;

        modules = [
          ./hosts/butcher
          nur.nixosModules.nur
        ];
      };

      soy = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          pkgs = import inputs.nixpkgs {
            system = system;
            config.allowUnfree = true;
          };
          GUI = true;
        } // inputs;

        modules = [
          ./hosts/soy
          nur.nixosModules.nur
          vscode-server.nixosModules.default
        ];
      };
    };
  };
}
