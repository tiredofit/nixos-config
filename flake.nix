{
  description = "Tired of I.T! NixOS Configuration";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      #"https://hyprland.cachix.org"

    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      #"nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      #"nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    #nix-gaming = {
    #  url = "github:fufexan/nix-gaming";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    #nixpkgs-wayland = {
    #  url = "github:nix-community/nixpkgs-wayland";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSystem = f: lib.genAttrs systems (sys: f pkgsFor.${sys});
      pkgsFor = lib.genAttrs systems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
            overlays = [
              inputs.nixpkgs-wayland.overlay
              outputs.overlays.additions
              outputs.overlays.modifications
              outputs.overlays.unstable-packages
        ];
      });
    in
    {
      inherit lib;
      nixosModules = import ./modules;
      overlays = import ./overlays {inherit inputs;};
      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      formatter = forEachSystem (pkgs: pkgs.nixpkgs-fmt);

      nixosConfigurations = {
        expedition = lib.nixosSystem { # Server Added 2024-07-04
          modules = [ ./hosts/expedition ];
          specialArgs = { inherit inputs outputs; };
        };

        seed = lib.nixosSystem { # Server Added 2024-03-26
          modules = [ ./hosts/seed ];
          specialArgs = { inherit inputs outputs; };
        };

        tentacle = lib.nixosSystem { # Server Added 2023-10-25
          modules = [ ./hosts/tentacle ];
          specialArgs = { inherit inputs outputs; };
        };

        beef = lib.nixosSystem { # Workstation
          modules = [ ./hosts/beef ];
          specialArgs = { inherit inputs outputs; };
        };

        beer = lib.nixosSystem { # Bar
          modules = [ ./hosts/beer ];
          specialArgs = {
            inherit inputs outputs;
            kioskUsername = "dave";
            kioskURL = "https://beer.tiredofit.ca";
          };
        };

        butcher = lib.nixosSystem { # Local Server
          modules = [ ./hosts/butcher ];
          specialArgs = { inherit inputs outputs; };
        };

        nakulaptop = lib.nixosSystem { # Laptop
          modules = [ ./hosts/nakulaptop ];
          specialArgs = { inherit inputs outputs; };
        };
      };
    };
}
