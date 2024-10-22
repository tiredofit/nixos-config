{
  description = "Tired of I.T! NixOS Configuration";

  nixConfig = {
    experimental-features = [
      "flakes"
      "nix-command"
    ];
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://hyprland.cachix.org"

    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };

  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs = inputs @ { self, nixpkgs, nixpkgs-unstable, ...}:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      forEachSystem = f: lib.genAttrs systems (sys: f pkgsFor.${sys});
      pkgsFor = lib.genAttrs systems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
            outputs.overlays.additions
            outputs.overlays.modifications
            outputs.overlays.unstable-packages
        ];
      });
    in
    {
      inherit lib;
      formatter = forEachSystem (pkgs: pkgs.nixpkgs-fmt);
      docs = forEachSystem (pkgs: pkgs.callPackage ./docs/mkDocs.nix {inherit inputs;});

      nixosModules = import ./modules;
      overlays = import ./overlays {inherit inputs;};
      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      nixosConfigurations = {
        beef = lib.nixosSystem {
          modules = [ ./hosts/beef ];
          specialArgs = { inherit inputs outputs; };
        };

        butcher = lib.nixosSystem {
          modules = [ ./hosts/butcher ];
          specialArgs = { inherit inputs outputs; };
        };

        expedition = lib.nixosSystem {
          modules = [ ./hosts/expedition ];
          specialArgs = { inherit inputs outputs; };
        };

        nakulaptop = lib.nixosSystem {
          modules = [ ./hosts/nakulaptop ];
          specialArgs = { inherit inputs outputs; };
        };

        seed = lib.nixosSystem {
          modules = [ ./hosts/seed ];
          specialArgs = { inherit inputs outputs; };
        };

        tentacle = lib.nixosSystem {
          modules = [ ./hosts/tentacle ];
          specialArgs = { inherit inputs outputs; };
        };
      };
    };
}
