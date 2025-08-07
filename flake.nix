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
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-modules = {
      url = "github:tiredofit/nix-modules";
      #url = "path:/home/dave/src/nix-modules";
    };
    apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    asahi-firmware = {
      url = "git+https://github.com/tiredofit/asahi-firmware.git";
      flake = false;
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    herald = {
      url = "github:nfrastack/herald";
      #url = "path:/home/dave/src/gh/herald";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    zeroplex = {
      url = "github:nfrastack/zeroplex";
      #url = "path:/home/dave/src/gh/zeroplex";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, nixpkgs-stable, nixpkgs-unstable, ...}:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      # Create package sets for each system
      forAllSystems = f: lib.genAttrs systems (system: f system);

      # Create a stable/unstable overlay
      nixpkgsSelection = { stable, unstable }: final: prev: {
        stable = import stable {
          inherit (prev) system;
          config = prev.config;
          overlays = [];
        };
        unstable = import unstable {
          inherit (prev) system;
          config = prev.config;
          overlays = [];
        };
      };

      pkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
            outputs.overlays.additions
            outputs.overlays.modifications
            outputs.overlays.stable-packages
            outputs.overlays.unstable-packages
        ];
      });

      forEachSystem = f: lib.genAttrs systems (sys: f pkgsFor.${sys});
    in
    {
      inherit lib;
      formatter = forEachSystem (pkgs: pkgs.nixpkgs-fmt);

      overlays = import ./overlays {inherit inputs; additions = final: prev: {
      };};
      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });

      mkSystem = { hostPath, packages ? "stable", system ? "x86_64-linux", extraModules ? [] }:
        let
          selectedNixpkgs = if packages == "stable"
                            then nixpkgs-stable
                            else nixpkgs-unstable;

          selectedHomeManager = if packages == "stable"
                               then inputs.home-manager-stable
                               else inputs.home-manager-unstable;

          systemPkgs = import selectedNixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
              allowBroken = false;
              allowUnsupportedSystem = true;
            };
            overlays = builtins.attrValues outputs.overlays ++ [
              (final: prev: {
                stable = import nixpkgs-stable {
                  inherit system;
                  config.allowUnfree = true;
                  overlays = [];
                };
                unstable = import nixpkgs-unstable {
                  inherit system;
                  config.allowUnfree = true;
                  overlays = [];
                };
              })
            ];
          };
        in
        lib.nixosSystem {
          modules = [
            selectedHomeManager.nixosModules.home-manager
            hostPath
            {
              _module.args.nixpkgsBranch = packages;
            }
          ] ++ extraModules;
          specialArgs = {
            inherit self inputs outputs;
            home-manager = selectedHomeManager;
          };
          inherit (systemPkgs) system;
          pkgs = systemPkgs;
        };

      nixosConfigurations = {
        atlas = self.mkSystem {
          hostPath = ./hosts/atlas;
          packages = "stable";
          system = "aarch64-linux";
        };

        beef = self.mkSystem {
          hostPath = ./hosts/beef;
          packages = "stable";
        };

        enigma = self.mkSystem {
          hostPath = ./hosts/enigma;
          packages = "stable";
        };

        entropy = self.mkSystem {
          hostPath = ./hosts/entropy;
          packages = "unstable";
        };

        mirage = self.mkSystem {
          hostPath = ./hosts/mirage;
          packages = "stable";
          system = "aarch64-linux";
          extraModules = [ ./modules ];
        };

        nakulaptop = self.mkSystem {
          hostPath = ./hosts/nakulaptop;
          packages = "unstable";
        };

        nomad = self.mkSystem {
          hostPath = ./hosts/nomad;
          packages = "unstable";
          extraModules = [ ./modules ];
        };
      };

      profiles = lib.mkOption {
        type = with lib.types; attrsOf (attrsOf anything);
        default = {};
      };
    };
}
