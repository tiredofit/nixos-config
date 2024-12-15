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
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-modules.url = "github:tiredofit/nix-modules";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
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

      overlays = import ./overlays {inherit inputs;};
      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      nixosConfigurations = {
        beef = lib.nixosSystem {
          modules = [ ./hosts/beef ];
          specialArgs = { inherit self inputs outputs; };
        };

        butcher = lib.nixosSystem {
          modules = [ ./hosts/butcher ];
          specialArgs = { inherit self inputs outputs; };
        };

        expedition = lib.nixosSystem {
          modules = [ ./hosts/expedition ];
          specialArgs = { inherit self inputs outputs; };
        };

        nakulaptop = lib.nixosSystem {
          modules = [ ./hosts/nakulaptop ];
          specialArgs = { inherit self inputs outputs; };
        };

        seed = lib.nixosSystem {
          modules = [ ./hosts/seed ];
          specialArgs = { inherit self inputs outputs; };
        };

        tentacle = lib.nixosSystem {
          modules = [ ./hosts/tentacle ];
          specialArgs = { inherit self inputs outputs; };
        };
      };
    };
}
