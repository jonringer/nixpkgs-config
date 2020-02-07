{ config, lib, pkgs, ... }:

let
  bashsettings = import ./bash.nix;
  vimsettings = import ./vim.nix;
  packages = import ./packages.nix;
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.packages = packages pkgs;

  services.compton = {
    enable = true;
    inactiveOpacity = "0.8";
    inactiveDim = "0.15";
  };

  services.polybar = {
    enable = true;
    package = pkgs.polybarFull;
    config = ./polybar-config;
    script = ''polybar nord &'';
  };

  programs.alacritty.enable = true;

  programs.alacritty.settings = {
    keybindings = [
      { key = "Equals";     mods = "Control";     action = "IncreaseFontSize"; }
      { key = "Add";        mods = "Control";     action = "IncreaseFontSize"; }
      { key = "Subtract";   mods = "Control";     action = "DecreaseFontSize"; }
      { key = "Minus";      mods = "Control";     action = "DecreaseFontSize"; }
    ];

    colors = {
      primary = {
        background =  "0x002b36";
        foreground =  "0xEBEBEB";
      };

      normal = {
        black =    "0x0d0d0d";
        red =      "0xFF301B";
        green =    "0xA0E521";
        yellow =   "0xFFC620";
        blue =     "0x1BA6FA";
        magenta =  "0x8763B8";
        cyan =     "0x21DEEF";
        white =    "0xEBEBEB";
      };

      bright = {
        black =    "0x6D7070";
        red =      "0xFF4352";
        green =    "0xB8E466";
        yellow =   "0xFFD750";
        blue =     "0x1BA6FA";
        magenta =  "0xA578EA";
        cyan =     "0x73FBF1";
        white =    "0xFEFEF8";
      };
    };
    #colors = {
    #  primary = {
    #    background = "0x002b36"; # base03
    #    foreground = "0x839496"; # base0
    #  };

    #  cursor = {
    #    text =   "0x002b36"; # base03
    #    cursor = "0x839496"; # base0
    #  };

    #  normal = {
    #    black=   "0x073642"; # base02
    #    red=     "0xdc322f"; # red
    #    green=   "0x859900"; # green
    #    yellow=  "0xb58900"; # yellow
    #    blue=    "0x268bd2"; # blue
    #    magenta= "0xd33682"; # magenta
    #    cyan=    "0x2aa198"; # cyan
    #    white=   "0xeee8d5"; # base2
    #  };

    #  bright= {
    #    black=   "0x002b36"; # base03
    #    red=     "0xcb4b16"; # orange
    #    green=   "0x586e75"; # base01
    #    yellow=  "0x657b83"; # base00
    #    blue=    "0x839496"; # base0
    #    magenta= "0x6c71c4"; # violet
    #    cyan=    "0x93a1a1"; # base1
    #    white=   "0xfdf6e3"; # base3
    #  };
    #};
  };

  programs.bash = bashsettings;
  programs.neovim = vimsettings pkgs;

  programs.direnv.enable = true;
  programs.htop.enable = true;
  programs.jq.enable = true;
  programs.ssh.enable = true;
  programs.fzf.enable = true;

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      ms-python.python
    ];
  };

  programs.git = {
    enable = true;
    userName = "Jonathan Ringer";
    userEmail = "jonringer117@gmail.com";
    aliases = {
      a = "add";
      c = "commit";
      ca = "commit --amend";
      can = "commit --amend --no-edit";
      cl = "clone";
      cm = "commit -m";
      co = "checkout";
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
  };

  xdg.enable = true;

  xsession = {
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
        ];
        assigns = {
          "2: web" = [{ class = "^Firefox$"; }];
          "4" = [{ class = "^Steam$"; }];
        };

        keybindings = let mod = config.modifier; in {
          "${mod}+w" = "exec firefox";
          "${mod}+s" = "exec steam";
          "${mod}+m" = "exec spotify";
          "${mod}+Return" = "exec alacritty";
          "${mod}+c" = "kill";
          "${mod}+Shift+h" = "exec dm-tool switch-to-greeter";
          "${mod}+Shift+m" = "exec amixer -q sset Master toggle";
          "XF86AudioRaiseVolume" = "exec amixer -q sset Master 10%+";
          "XF86AudioLowerVolume" = "exec amixer -q sset Master 10%-";
          "XF86AudioMute" = "exec amixer -q sset Master toggle";

          "${mod}+Shift+grave" = "move scratchpad";
          "${mod}+grave" = "scratchpad show";
          "${mod}+j" = "focus left";
          "${mod}+k" = "focus down";
          "${mod}+l" = "focus up";
          "${mod}+semicolon" = "focus right";
          "${mod}+Left" = "focus left";
          "${mod}+Down" = "focus down";
          "${mod}+Up" = "focus up";
          "${mod}+Right" = "focus right";
          "${mod}+Shift+j" = "move left";
          "${mod}+Shift+k" = "move down";
          "${mod}+Shift+l" = "move up";
          "${mod}+Shift+semicolon" = "move right";
          "${mod}+Shift+Left" = "move left";
          "${mod}+Shift+Down" = "move down";
          "${mod}+Shift+Up" = "move up";
          "${mod}+Shift+Right" = "move right";
          "${mod}+h" = "split h";
          "${mod}+v" = "split v";
          "${mod}+f" = "fullscreen";
          "${mod}+Shift+s" = "layout stacking";
          "${mod}+Shift+t" = "layout tabbed";
          "${mod}+Shift+f" = "floating toggle";
          "${mod}+space" = "focus mode_toggle";
          "${mod}+1" = "workspace 1";
          "${mod}+2" = "workspace \"2: web\"";
          "${mod}+3" = "workspace 3";
          "${mod}+4" = "workspace 4";
          "${mod}+5" = "workspace 5";
          "${mod}+6" = "workspace 6";
          "${mod}+7" = "workspace 7";
          "${mod}+8" = "workspace 8";
          "${mod}+9" = "workspace 9";
          "${mod}+0" = "workspace 10";
          "${mod}+Shift+1" = "move container to workspace 1";
          "${mod}+Shift+2" = "move container to workspace \"2: web\"";
          "${mod}+Shift+3" = "move container to workspace 3";
          "${mod}+Shift+4" = "move container to workspace 4";
          "${mod}+Shift+5" = "move container to workspace 5";
          "${mod}+Shift+6" = "move container to workspace 6";
          "${mod}+Shift+7" = "move container to workspace 7";
          "${mod}+Shift+8" = "move container to workspace 8";
          "${mod}+Shift+9" = "move container to workspace 9";
          "${mod}+Shift+0" = "move container to workspace 10";
          "${mod}+Shift+r" = "restart";
          "${mod}+Shift+e" = "exec \"i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -b 'Yes, exit i3' 'i3-msg exit'\"";
        };
      };
      extraConfig = ''
        for_window [class="^.*"] border pixel 2
        #exec systemctl --user import-environment
        exec systemctl --user restart graphical-session.target
      '';
    };
  };
}
