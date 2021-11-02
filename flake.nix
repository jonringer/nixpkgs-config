{
  description = "Home-manager configuration";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";

    polybar-scripts = {
      # needed for pipewire integration, follow upstream after
      # https://github.com/polybar/polybar-scripts/pull/320 gets merged
      url = "github:victortrac/polybar-scripts";
      flake = false;
    };
  };

  outputs = { self, home-manager, polybar-scripts, nixpkgs, utils }:
    let
      localOverlay = _: final: {
        inherit polybar-scripts;
        polybar-pipewire = final.callPackage ./nix/polybar-pipewire.nix { };
      };

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
        extraSpecialArgs = {
          withGUI = true;
          isDesktop = true;
          networkInterface = "enp5s0";
          inherit localOverlay;
        };
      };
    inherit home-manager;
  };
}
