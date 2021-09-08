{
  description = "Home-manager configuration";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, home-manager, nixpkgs, utils }:
    let
      localOverlay = _: _: { };

      pkgsForSystem = system: import nixpkgs {
        overlays = [
          localOverlay
        ];
        inherit system;
      };
    in utils.lib.eachSystem [ "x86_64-linux" ] (system: rec {
      legacyPackages = pkgsForSystem system;
  }) // {
    # non-system suffixed items should go here
    overlay = localOverlay;
    nixosModules.home = import ./home.nix; # attr set or list
    homeConfigurations.jon = home-manager.lib.homeManagerConfiguration {
        system = "x86_64-linux";
        configuration = import ./home.nix;
        homeDirectory = "/home/jon";
        username = "jon";
      };
    inherit home-manager;
  };
}
