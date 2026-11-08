# ekapkgs home configuration
#
# Equivalent of home.nix but targeting ekaos eval-home.nix
# instead of home-manager. Import this as a module via eval-home.
#
# Reference: home.nix (the original home-manager config)
{ config, lib, pkgs, withGUI, isDesktop, networkInterface, ... }:

let
  bashsettings = import ./bash.nix pkgs;
  vimsettings = import ./vim.nix;
  packages = import ./packages.nix;

  inherit (lib) mkIf;
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;

  # Build neovim with plugins via wrapNeovim (no programs.neovim module)
  neovimConfigured = pkgs.wrapNeovim pkgs.neovim-unwrapped {
    viAlias = true;
    vimAlias = true;
    configure = {
      customRC = builtins.readFile ./vim-extra-conf.viml;
      packages.myPlugins = {
        start = (vimsettings pkgs).plugins;
      };
    };
  };

  cocSettings = import ./coc-settings.nix pkgs;

  obsWithPlugins = pkgs.wrapOBS {
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
    ];
  };
in
{
  home.users.jon = {
    stateVersion = "21.11";

    # --- Packages ---
    packages = packages pkgs withGUI
      ++ [ neovimConfigured ]
      ++ lib.optionals withGUI [
        (pkgs.vscode-fhsWithPackages (ps: with ps; [ zlib rustup ]))
        pkgs.waybar
        obsWithPlugins
      ];

    # --- Session environment ---
    sessionVariables = {
      EDITOR = "vim";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";
      XDG_CACHE_HOME = "$HOME/.cache";
    };

    sessionPath = [
      "$HOME/.cargo/bin"
      "$HOME/.config/nixpkgs/bin"
    ];

    shellAliases = bashsettings.shellAliases;

    # --- programs.direnv ---
    programs.direnv.enable = true;

    # --- programs.fzf ---
    programs.fzf.enable = true;

    # --- programs.htop ---
    programs.htop = {
      enable = true;
      settings = {
        left_meters = [ "LeftCPUs2" "Memory" "Swap" ];
        right_meters = [ "RightCPUs2" "Tasks" "LoadAverage" "Uptime" ];
        show_program_path = 0;
        tree_view = 1;
      };
    };

    # --- programs.bash ---
    programs.bash = {
      enable = true;
      initExtra = bashsettings.initExtra;
    };

    # --- programs.git ---
    programs.git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = {
          name = "Jonathan Ringer";
          email = "jonringer117@gmail.com";
        };
        alias = {
          a = "add";
          c = "commit";
          ca = "commit --amend";
          can = "commit --amend --no-edit";
          cl = "clone";
          cm = "commit -m";
          co = "checkout";
          cp = "cherry-pick";
          cpx = "cherry-pick -x";
          d = "diff";
          f = "fetch";
          fo = "fetch origin";
          fu = "fetch upstream";
          lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
          lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
          pl = "pull";
          pr = "pull -r";
          ps = "push";
          psf = "push -f";
          rb = "rebase";
          rbi = "rebase -i";
          r = "remote";
          ra = "remote add";
          rr = "remote rm";
          rv = "remote -v";
          rs = "remote show";
          st = "status";
        };
        merge = {
          tool = "vimdiff";
          conflictstyle = "diff3";
        };
        pull.rebase = true;
        mergetool.prompt = "false";
      };
      signing = {
        key = "5C841D3CFDFEC4E0";
        signByDefault = false;
      };
      includes = [
        {
          condition = "gitdir:~/work/";
          contents = {
            user = {
              name = "Jonathan Ringer";
              email = "jringer@anduril.com";
              signingKey = "7B8CFA0F33328D9A";
            };
          };
        }
        {
          condition = "gitdir:~/projects/nixpkgs";
          contents = {
            gc.auto = 0;
            fetch.prune = false;
          };
        }
      ];
    };

    # --- programs.ssh ---
    programs.ssh = {
      enable = true;
      includes = [ "~/.ssh/config.d/*" ];
      matchBlocks = {
        "mac" = {
          hostname = "10.0.0.236";
          port = 22;
          identityFile = "/home/jon/.ssh/id_ed25519";
          forwardAgent = true;
          user = "jon";
          remoteForwards = [{
            bind.address = "/run/user/1000/gnupg/S.gpg-agent";
            host.address = "/run/user/1000/gnupg/S.gpg-agent.extra";
          }];
          extraOptions = {
            ServerAliveInterval = "60";
          };
        };
        "build" = {
          hostname = "10.0.0.21";
          port = 22;
          identityFile = "/home/jon/.ssh/id_ed25519";
          user = "root";
        };
        "external" = {
          hostname = "jonringer.us";
          port = 2222;
          identityFile = "/home/jon/.ssh/id_ed25519";
          forwardAgent = true;
          user = "jon";
          remoteForwards = [{
            bind.address = "/run/user/1000/gnupg/S.gpg-agent";
            host.address = "/run/user/1000/gnupg/S.gpg-agent.extra";
          }];
        };
        "server" = {
          hostname = "10.0.0.41";
          port = 22;
          identityFile = "/home/jon/.ssh/id_ed25519";
          user = "jon";
        };
        "pi" = {
          hostname = "10.0.0.220";
          port = 22;
          identityFile = "/home/jon/.ssh/id_ed25519";
          user = "jon";
          remoteForwards = [{
            bind.address = "/run/user/1000/gnupg/S.gpg-agent";
            host.address = "/run/user/1000/gnupg/S.gpg-agent.extra";
          }];
        };
        "*" = {
          forwardAgent = true;
          identitiesOnly = true;
          extraOptions = {
            AddKeysToAgent = "yes";
          };
        };
      };
    };

    # --- programs.gpg-agent ---
    programs.gpg-agent = {
      enable = isLinux;
      enableSshSupport = isLinux;
      enableExtraSocket = withGUI;
      pinentryPackage = if withGUI then pkgs.pinentry-gnome3 else pkgs.pinentry-curses;
      defaultCacheTtl = 7200;
      defaultCacheTtlSsh = 7200;
    };

    # --- home.file ---

    # Neovim CoC settings
    file.".config/nvim/coc-settings.json".text = builtins.toJSON cocSettings;

    # Alacritty config (GUI only)
    file.".config/alacritty/alacritty.toml" = mkIf withGUI {
      text = ''
        [colors.primary]
        background = "0x002b36"
        foreground = "0xEBEBEB"

        [colors.normal]
        black = "0x0d0d0d"
        red = "0xFF301B"
        green = "0xA0E521"
        yellow = "0xFFC620"
        blue = "0x1BA6FA"
        magenta = "0x8763B8"
        cyan = "0x21DEEF"
        white = "0xEBEBEB"

        [colors.bright]
        black = "0x6D7070"
        red = "0xFF4352"
        green = "0xB8E466"
        yellow = "0xFFD750"
        blue = "0x1BA6FA"
        magenta = "0xA578EA"
        cyan = "0x73FBF1"
        white = "0xFEFEF8"
      '';
    };

    # Claude Code settings
    file.".claude/settings.json".text = builtins.toJSON {
      permissions = {
        allow = [
          "Read"
          "Glob"
          "Grep"
          "Bash(*)"
          "WebFetch"
          "WebSearch"
          "Agent"
        ];
      };
      enabledPlugins = {
        "caveman@caveman" = true;
        "rust-analyzer-lsp@claude-plugins-official" = true;
      };
      alwaysThinkingEnabled = false;
      effortLevel = "high";
    };
  };
}
