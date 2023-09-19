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
      pkgsForSystem = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      mkHomeConfiguration = args: home-manager.lib.homeManagerConfiguration (rec {
        modules = [ (import ./home.nix) ];
        pkgs = pkgsForSystem (args.system or "x86_64-linux");
      } // { inherit (args) extraSpecialArgs; });

    in utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ] (system: rec {
      legacyPackages = pkgsForSystem system;
  }) // {
    # non-system suffixed items should go here
    nixosModules.home = import ./home.nix; # attr set or list

    homeConfigurations.jon = mkHomeConfiguration {
      extraSpecialArgs = {
        withGUI = true;
        isDesktop = true;
        networkInterface = "enp5s0";
      };
    };

    homeConfigurations.server = mkHomeConfiguration {
      extraSpecialArgs = {
        withGUI = false;
        isDesktop = false;
        networkInterface = "enp68s0";
      };
    };

    homeConfigurations.laptop = mkHomeConfiguration {
      extraSpecialArgs = {
        withGUI = true;
        isDesktop = true;
        networkInterface = "wlp1s0";
      };
    };

    homeConfigurations.mac-mini = mkHomeConfiguration {
      system = "aarch64-darwin";
      extraSpecialArgs = {
        withGUI = false;
        isDesktop = false;
        networkInterface = "en1";
      };
    };

    inherit home-manager;
    inherit (home-manager) packages;
  };
}
