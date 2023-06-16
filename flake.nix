{
  description = "Tired of I.T! NixOS configuration";  

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";

    stable.url = "github:nixos/nixpkgs/nixos-23.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    hyprland.url = "github:hyprwm/Hyprland/v0.26.0";
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";

    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nur.url = "github:nix-community/NUR";

    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };  
  
  outputs = inputs@{
    self,
    nixpkgs,
    stable,
    unstable,
    impermanence,
    nixos-hardware,
    nur,
    vscode-server,
    ...
  }: {
 
   nixosConfigurations = {
      beef = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          pkgs-stable = import inputs.stable {
            system = system; 
            config.allowUnfree = true;
          };
        } // inputs;

        modules = [
          ./hosts/beef
          nur.nixosModules.nur
        ];
      };
    };
  };
}
