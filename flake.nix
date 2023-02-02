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
            rev = "5fbbb0dbaeda257427659f9168daa39c2f5e9b75";
            sha256 = "sha256-jj12GlDN/hYdwDqeOqwX97lOlvNCmCWaQjRB3+4+w7M=";
          };
        });
      };

      pkgsForSystem = system: import nixpkgs {
        overlays = [
          localOverlay
        ];
        inherit system;
        config.allowUnfree = true;
      };

      mkHomeConfiguration = args: home-manager.lib.homeManagerConfiguration (rec {
        modules = [ (import ./home.nix) ];
        pkgs = pkgsForSystem (args.system or "x86_64-linux");
      } // { inherit (args) extraSpecialArgs; });

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
