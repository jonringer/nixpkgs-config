{
  description = "Home configuration";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs?rev=7a17139823551e1fb824ccca70540ff99dea0ea2";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # TODO: switch to github:ekala-project/corepkgs once home module
    # changes are merged (enableExtraSocket, git includes contents,
    # ssh socket remoteForwards, gpg-agent pinentry auto-detection)
    core-pkgs.url = "git+file:///home/jon/projects/core-pkgs";
    core-pkgs.flake = false;
  };

  outputs = { self, home-manager, core-pkgs, nixpkgs, utils }:
    let
      pkgsForSystem = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # --- home-manager (current, known-working) ---

      mkHomeConfiguration = args: home-manager.lib.homeManagerConfiguration (rec {
        modules = [ (import ./home.nix) ] ++ (args.modules or []);
        pkgs = pkgsForSystem (args.system or "x86_64-linux");
      } // { inherit (args) extraSpecialArgs; });

      # --- ekapkgs home (migration target) ---

      evalHome = import "${core-pkgs}/ekaos/eval-home.nix";

      mkEkapkgsHome = args:
        let
          system = args.system or "x86_64-linux";
          pkgs = pkgsForSystem system;
          lib = pkgs.lib;
          result = evalHome { inherit lib pkgs; } {
            modules = [ (import ./ekapkgs-home.nix) ] ++ (args.modules or []);
            specialArgs = args.specialArgs or {};
          };
        in result.activationPackage;

      machineArgs = {
        jon = {
          withGUI = true;
          isDesktop = true;
          networkInterface = "enp5s0";
        };
        server = {
          withGUI = false;
          isDesktop = false;
          networkInterface = "enp68s0";
        };
        laptop = {
          withGUI = true;
          isDesktop = true;
          networkInterface = "wlp1s0";
        };
        work = {
          withGUI = true;
          isDesktop = true;
          networkInterface = "wlp192s0";
        };
        mac-mini = {
          withGUI = false;
          isDesktop = false;
          networkInterface = "en1";
        };
      };

    in utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ] (system: rec {
      legacyPackages = pkgsForSystem system;
      devShells.default = with legacyPackages; mkShell {
        packages = [ home-manager.packages.${system}.default ];
      };
  }) // {
    nixosModules.home = import ./home.nix;

    # --- home-manager configs (current) ---

    homeConfigurations.jon = mkHomeConfiguration {
      extraSpecialArgs = machineArgs.jon;
    };

    homeConfigurations.server = mkHomeConfiguration {
      extraSpecialArgs = machineArgs.server;
    };

    homeConfigurations.laptop = mkHomeConfiguration {
      extraSpecialArgs = machineArgs.laptop;
    };

    homeConfigurations.work = mkHomeConfiguration {
      modules = [ ({lib,...}:
      {
        home.username = lib.mkForce "jon";
        home.homeDirectory = lib.mkForce "/home/jon";
      })];
      extraSpecialArgs = machineArgs.work;
    };

    homeConfigurations.mac-mini = mkHomeConfiguration {
      extraSpecialArgs = machineArgs.mac-mini;
    };

    # --- ekapkgs home configs (migration target) ---
    # Build with: nix build .#ekapkgsHome.<machine>
    # Activate with: ekapkgs home switch .#ekapkgsHome.<machine>

    ekapkgsHome.jon = mkEkapkgsHome {
      specialArgs = machineArgs.jon;
    };

    ekapkgsHome.server = mkEkapkgsHome {
      specialArgs = machineArgs.server;
    };

    ekapkgsHome.laptop = mkEkapkgsHome {
      specialArgs = machineArgs.laptop;
    };

    ekapkgsHome.work = mkEkapkgsHome {
      specialArgs = machineArgs.work;
    };

    ekapkgsHome.mac-mini = mkEkapkgsHome {
      specialArgs = machineArgs.mac-mini;
    };

    inherit home-manager;
    inherit (home-manager) packages;
  };
}
