{ config, lib, pkgs, specialArgs, ... }:

let
  bashsettings = import ./bash.nix pkgs;
  vimsettings = import ./vim.nix;
  packages = import ./packages.nix;

  # hacky way of determining which machine I'm running this from
  inherit (specialArgs) withGUI isDesktop networkInterface localOverlay;

  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isLinux isDarwin;
in
{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ localOverlay ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.packages = packages pkgs withGUI;

  home.file.".config/nvim/coc-settings.json".source = ./coc-settings.json;

  services.picom = mkIf withGUI {
    enable = true;
    inactiveOpacity = "0.8";
    inactiveDim = "0.15";
    fadeExclude = [
      "window_type *= 'menu'"
      "name ~= 'Firefox\$'"
      "focused = 1"
    ];
    vSync = true; # workaround with nvidia drivers
  };

  home.file.".config/polybar/pipewire.sh" = mkIf withGUI {
    source = pkgs.polybar-pipewire;
    executable = true;
  };
  services.polybar = mkIf withGUI {
    enable = true;
    package = pkgs.polybarFull;
    config = pkgs.substituteAll {
      src = ./polybar-config;
      interface = networkInterface;
    };
    script = ''
      for m in $(polybar --list-monitors | ${pkgs.coreutils}/bin/cut -d":" -f1); do
        MONITOR=$m polybar nord &
      done
    '';
  };

  services.lorri.enable = isLinux;
  services.pulseeffects.enable = false;
  services.pulseeffects.preset = "vocal_clarity";
  services.gpg-agent.enable = isLinux;
  services.gpg-agent.enableExtraSocket = withGUI;
  services.gpg-agent.enableSshSupport = isLinux;

  programs.alacritty = (import ./alacritty.nix) withGUI;
  programs.bash = bashsettings;
  programs.neovim = vimsettings pkgs;

  programs.direnv.enable = true;
  programs.htop = {
    enable = true;
    settings = {
      left_meters = [ "LeftCPUs2" "Memory" "Swap" ];
      left_right = [ "RightCPUs2" "Tasks" "LoadAverage" "Uptime" ];
      setshowProgramPath = false;
      treeView = true;
    };
  };
  programs.jq.enable = true;
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    extraConfig = ''
      Include ~/.ssh/config.d/*

      Host mac
        HostName 10.0.0.236
        Port 22
        IdentityFile /home/jon/.ssh/id_rsa
        ForwardAgent yes
        User jon
        ServerAliveInterval 60
        RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra

      Host build
        HostName 10.0.0.21
        Port 22
        IdentityFile /home/jon/.ssh/id_rsa
        User root

      Host external
        HostName 73.157.50.82
        Port 2222
        IdentityFile /home/jon/.ssh/id_rsa
        ForwardAgent yes
        User jon
        RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra

      Host server
        HostName 10.0.0.21
        Port 22
        IdentityFile /home/jon/.ssh/id_rsa
        User jon

      Host pi
        HostName 10.0.0.220
        Port 22
        IdentityFile /home/jon/.ssh/id_rsa
        User jon

      Host *
        ForwardAgent yes
        GSSAPIAuthentication no
        RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra
      '';
  };
  programs.fzf.enable = true;

  programs.vscode = mkIf withGUI {
    enable = true;
    package = pkgs.vscode-fhsWithPackages (pkgs: with pkgs; [ zlib rustup ]);
    #extensions = with pkgs.vscode-extensions; [
    #  vscodevim.vim
    #  ms-python.python
    #];
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Jonathan Ringer";
    userEmail = "jonringer117@gmail.com";
    signing = {
      key = "5C841D3CFDFEC4E0";
      signByDefault = true;
    };
    aliases = {
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
    extraConfig = {
      merge = {
        tool = "vimdiff";
        conflictstyle = "diff3";
      };
      pull = {
        rebase=true;
      };
      mergetool.prompt = "false";
    };
    includes = [
      # use different signing key
      #{
      #  condition = "gitdir:~/work/";
      #  contents = {
      #    user = {
      #      name = "Jonathan Ringer";
      #      email = "jonathan.ringer@iohk.io";
      #      signingKey = "523B37EC8FB6E3A2";
      #    };
      #  };
      #}
      {
        condition = "gitdir:~/comm/";
        contents = {
          user = {
            name = "Jonathan Ringer";
            email = "jonathan.ringer@comm.app";
            signingKey = "SHA256:KtR4tLVU9XtEqWk5V1IuBfpZ/vvtAtSxxE49EE47MWQ";
          };
        };
      }
      # prevent background gc thread from constantly blocking reviews
      {
        condition = "gitdir:~/projects/nixpkgs";
        contents = {
          gc.auto = 0;
          fetch.prune = false;
        };
      }

    ];
  };

  xdg.enable = true;

  xsession = mkIf withGUI {
    enable = true;
    windowManager.i3 = rec {
      enable = true;
      package = pkgs.i3-gaps;
      config = {
        modifier = "Mod4";
        bars = [ ]; # use polybar instead

        gaps = {
          inner = 12;
          outer = 5;
          smartGaps = true;
          smartBorders = "off";
        };

        startup = [
          { command = "exec firefox"; }
          { command = "exec steam"; }
          { command = "exec Discord"; }
        ] ++ lib.optionals isDesktop [
          { command = "xrand --output HDMI-0 --right-of DP-4"; notification = false; }
        ] ++ [
          # allow polybar to resize itself
          { command = "systemctl --user restart polybar"; always = true; notification = false; }
        ];
        assigns = {
          "2: web" = [{ class = "^Firefox$"; }];
          "4" = [{ class = "^Steam$"; }];
          "6" = [{ class = "HexChat$"; }];
          "7" = [{ class = "^Discord$"; }];
        };

        keybindings = import ./i3-keybindings.nix config.modifier;
      };
      extraConfig = ''
        for_window [class="^.*"] border pixel 2
        #exec systemctl --user import-environment
      '' + lib.optionalString isDesktop ''
        workspace "2: web" output HDMI-0
        workspace "7" output HDMI-0
      '';
    };
  };
}
