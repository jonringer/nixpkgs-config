{ config, lib, pkgs, specialArgs, ... }:

let
  bashsettings = import ./bash.nix pkgs;
  vimsettings = import ./vim.nix;
  packages = import ./packages.nix;

  # hacky way of determining which machine I'm running this from
  inherit (specialArgs) withGUI isDesktop networkInterface;

  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isLinux isDarwin;
in
{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.packages = packages pkgs withGUI;
  home.homeDirectory = "/home/jon";
  home.username = "jon";
  home.stateVersion = "21.11";

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
        HostName jonringer.us
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
        RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra

      Host *
        ForwardAgent yes
        AddKeysToAgent yes
      '';
  };
  programs.fzf.enable = true;

  programs.vscode = mkIf withGUI {
    enable = true;
    package = pkgs.vscode-fhsWithPackages (pkgs: with pkgs; [ zlib rustup ]);
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Jonathan Ringer";
    userEmail = "jonringer117@gmail.com";
    difftastic.enable = true;
    signing = {
      key = "5C841D3CFDFEC4E0";
      signByDefault = false;
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
      git.path = toString pkgs.git;
    };
    includes = [
      # use different signing key
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

  programs.obs-studio = {
    enable = withGUI;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
    ];
  };

}
