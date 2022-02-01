{
  description = "Home-manager configuration";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, home-manager, nixpkgs, utils }:
    let
      localOverlay = prev: final: {
        polybar-pipewire = final.callPackage ./nix/polybar.nix { };
        nixpkgs-review-fixed = prev.nixpkgs-review.overrideAttrs (oldAttrs: {
          src = prev.fetchFromGitHub {
            owner = "Mic92";
            repo = "nixpkgs-review";
            rev = "refs/pull/254/head";
            sha256 = "sha256-I5VRLB9IUWYMh+QvT8qkzJG7PvhaQsTnNcF7oEZA3dg=";
          };
        });
      };

      pkgsForSystem = system: import nixpkgs {
        overlays = [
          localOverlay
        ];
        inherit system;
      };

      mkHomeConfiguration = args: home-manager.lib.homeManagerConfiguration (rec {
        system = args.system or "x86_64-linux";
        configuration = import ./home.nix;
        homeDirectory = "/home/jon";
        username = "jon";
        pkgs = pkgsForSystem system;
      } // args);

    in utils.lib.eachSystem [ "x86_64-linux" ] (system: rec {
      legacyPackages = pkgsForSystem system;
  }) // {
    # non-system suffixed items should go here
    overlay = localOverlay;
    nixosModules.home = import ./home.nix; # attr set or list

    homeConfigurations.jon = mkHomeConfiguration {
      extraSpecialArgs = {
        withGUI = true;
        isDesktop = true;
        networkInterface = "enp5s0";
        inherit localOverlay;
      };
    };

    homeConfigurations.server = mkHomeConfiguration {
      extraSpecialArgs = {
        withGUI = false;
        isDesktop = false;
        networkInterface = "enp68s0";
        inherit localOverlay;
      };
    };

    homeConfigurations.laptop = mkHomeConfiguration {
      extraSpecialArgs = {
        withGUI = true;
        isDesktop = true;
        networkInterface = "wlp1s0";
        inherit localOverlay;
      };
    };

    homeConfigurations.mac-mini = mkHomeConfiguration {
      system = "aarch64-darwin";
      extraSpecialArgs = {
        withGUI = false;
        isDesktop = false;
        networkInterface = "en1";
        inherit localOverlay;
      };
    };

    inherit home-manager;
  };
}
