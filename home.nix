{ config, lib, pkgs, ... }:

let
  bashsettings = import ./bash.nix pkgs;
  vimsettings = import ./vim.nix;
  packages = import ./packages.nix;

  # hacky way of determining which machine I'm running this from
  withGUI = (builtins.pathExists ./withGUI && import ./withGUI);
  isDesktop = (builtins.pathExists ./isDesktop && import ./isDesktop);

  inherit (lib) mkIf;
in
{
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

  services.polybar = mkIf withGUI {
    enable = true;
    package = pkgs.polybarFull;
    config = ./polybar-config;
    script = ''
      for m in $(polybar --list-monitors | ${pkgs.coreutils}/bin/cut -d":" -f1); do
        MONITOR=$m polybar nord &
      done
    '';
  };

  services.lorri.enable = true;
  services.pulseeffects.enable = withGUI;
  services.pulseeffects.preset = "vocal_clarity";
  services.gpg-agent.enable = isDesktop;
  services.gpg-agent.enableSshSupport = true;
  services.gpg-agent.pinentryFlavor = "tty";
  services.gpg-agent.enableExtraSocket = isDesktop;

  programs.alacritty = import ./alacritty.nix;
  programs.bash = bashsettings;
  programs.neovim = vimsettings pkgs;

  programs.direnv.enable = true;
  programs.htop = {
    enable = true;
    meters.left = [ "LeftCPUs2" "Memory" "Swap" ];
    meters.right = [ "RightCPUs2" "Tasks" "LoadAverage" "Uptime" ];
    showProgramPath = false;
    treeView = true;
  };
  programs.jq.enable = true;
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host build
        HostName 10.0.0.21
        Port 22
        User root
        IdentitiesOnly yes
        IdentityFile /home/jon/.ssh/id_rsa

      Host server
        HostName 10.0.0.21
        Port 22
        User jon
        RemoteForward /run/user/1000/gnupg/S.gpg-agent ~/.gnupg/S.gpg-agent.extra
        IdentitiesOnly yes
        IdentityFile /home/jon/.ssh/id_rsa

      Host pi
        HostName 10.0.0.220
        Port 22
        User jon
        IdentitiesOnly yes
        IdentityFile /home/jon/.ssh/id_rsa

      Host *
        GSSAPIAuthentication no
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
      # TODO: figure out why gpg is a colossal PITA to use
      signByDefault = isDesktop;
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
      {
        condition = "gitdir:~/work/";
        contents = {
          user = {
            name = "Jonathan Ringer";
            email = "jonathan.ringer@iohk.io";
            signingKey = "523B37EC8FB6E3A2";
          };
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
