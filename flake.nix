{
  description = "Tired of I.T! NixOS Configuration";

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
    hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland/v0.28.0";
    hyprwm-contrib = {
      url = "github:hyprwm/contrib";
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

  outputs = { self, nixpkgs, ... }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSystem = f: lib.genAttrs systems (sys: f pkgsFor.${sys});
      pkgsFor = nixpkgs.legacyPackages;
    in
    {
      inherit lib;
      nixosModules = import ./modules/nixos;
      overlays = import ./overlays { inherit inputs outputs; };
      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      devShells = forEachSystem (pkgs: import ./shell.nix { inherit pkgs; });
      formatter = forEachSystem (pkgs: pkgs.nixpkgs-fmt);

      nixosConfigurations = {
        beef =  lib.nixosSystem { # Workstation
          modules = [ ./hosts/beef ];
          specialArgs = { inherit inputs outputs; };
        };

        beer =  lib.nixosSystem { # Bar
          modules = [ ./hosts/beer ];
          specialArgs = {
            inherit inputs outputs;
            kioskUsername = "dave";
            kioskURL = "https://beer.tiredofit.ca";
          };
        };

        butcher =  lib.nixosSystem { # Local Server
          modules = [ ./hosts/butcher ];
          specialArgs = { inherit inputs outputs; };
        };

        selecta =  lib.nixosSystem { # Production Station
          modules = [ ./hosts/selecta ];
          specialArgs = { inherit inputs outputs; };
        };

        soy =  lib.nixosSystem { # Fake assed wanna-be
          modules = [ ./hosts/soy ];
          specialArgs = { inherit inputs outputs; };
        };

        soy2 =  lib.nixosSystem { # Fake assed wanna-be
          modules = [ ./hosts/soy2 ];
          specialArgs = { inherit inputs outputs; };
          system = "x86_64-linux";
        };
      };
    };
}
