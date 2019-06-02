{ config, pkgs, ... }:

let
  customPlugins.omnisharp-vim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "omnisharp-vim";
    src = pkgs.fetchFromGitHub {
      owner = "omnisharp";
      repo = "omnisharp-vim";
      rev = "6258da895c5d49784d12bae0d7d994bf7ebb5602";
      sha256 = "1ajgwj248h0lqkl8a3ymgj10iq3fwmxrn6z69d24q7nnif37pva2";
    };
    dependences = [ pkgs.libuv pkgs.mono5 ];
    propagatedBuildInputs = [ pkgs.python3 ];
    postPatch = ''
      substituteInPlace python/bootstrap.py \
        --replace "vim.eval('g:OmniSharp_python_path')" "'~/.omnisharp/log'"
      substituteInPlace autoload/OmniSharp.vim \
        --replace "call OmniSharp#py#bootstrap()" \
                  "let g:OmniSharp_server_path = '~/omni/OmniSharp.exe'
                   let g:OmniSharp_server_use_mono = 1
                   call OmniSharp#py#bootstrap()"
    '';
  };
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    binutils
    cargo
    chromium
    cmake
    dbus
    direnv
    discord
    enlightenment.terminology
    firefox
    git
    gnumake
    htop
    ntfs3g
    exa
    fd
    cabal-install
    jetbrains.pycharm-community
    jetbrains.rider
    ghc
    mono
    openal
    python36
    spotify
    stack
    steam
    tree
    usbutils
    vlc
    vscode
    wget
    xpdf

    # vim plugin dependencies
    fzf
    ripgrep

    #haskell dependencies
    haskellPackages.hlint
  ];

  programs.direnv.enable = true;
  programs.htop.enable = true;
  programs.jq.enable = true;
  programs.ssh.enable = true;
  programs.fzf.enable = true;
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
    ];
  };

  programs.git = {
    enable = true;
    userName = "Jonathan Ringer";
    userEmail = "jonringer117@gmail.com";
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      sudo="sudo ";   # will now check for alias expansion after sudo
      ls="exa ";
      ll="exa -l --color=always";
      la="exa -a --color=always";
      lla="exa -al --color=always";
      ".."="cd ..";
      "..."="cd ../..";
      "...."="cd ../../..";
      ".2"="cd ../..";
      ".3"="cd ../../..";
      ".4"="cd ../../../..";
      ".5"="cd ../../../../..";
      # git
      g="git";
      gco="git checkout";
      gst="git status";

      # misc
      suspend="systemctl suspend";
    };
    initExtra = ''
      RED="\033[0;31m"
      GREEN="\033[0;32m"
      NO_COLOR="\033[m"
      BLUE="\033[0;34m"

      export PS1="$RED[\t] $GREEN\u@\h $NO_COLOR\w$BLUE\`__git_ps1\`$NO_COLOR\n$ "

      export PATH=$PATH:~/.cargo/bin

      editline() { vim ''${1%%:*} +''${1##*:}; }
      cd() { builtin cd "$@" && ls . ; }
      # Change dir with Fuzzy finding
      cf() {
        dir=$(fd . ''${1:-/home/jon/} --type d 2>/dev/null | fzf)
        cd "$dir"
      }
      # Change dir in Nix store
      cn() {
        dir=$(fd . '/nix/store/' --maxdepth 1 --type d 2>/dev/null | fzf)
        cd "$dir"
      }
      # search Files and Edit
      fe() {
        rg --files ''${1:-.} | fzf --preview 'cat {}' | xargs vim
      }
      # Search content and Edit
      se() {
        fileline=$(rg -n ''${1:-.} | fzf | awk '{print $1}' | sed 's/.$//')
        vim ''${fileline%%:*} +''${fileline##*:}
      }
    '';
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    configure = {
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [
          fzf-vim
          fzfWrapper
          gitgutter
          LanguageClient-neovim
          lightline-vim
          nerdtree
          supertab
          syntastic
          tabular
          vim-better-whitespace
          vim-multiple-cursors
          vimproc
          vimproc-vim

          # themes
          wombat256

          # language packages
          # Haskell
          vim-hoogle
          neco-ghc
          haskell-vim
          hlint-refactor-vim
          ghc-mod-vim

          # Nix
          vim-nix

          # Csharp
          customPlugins.omnisharp-vim # not added yet :)
        ];
      };

      customRC = ''
        colorscheme wombat256mod

        set number
        set expandtab
        set foldmethod=indent
        set foldnestmax=5
        set foldlevelstart=99
        set foldcolumn=0

        set list
        set listchars=tab:>-

        let g:better_whitespace_enabled=1
        let g:strip_whitespace_on_save=1
        let mapleader=' '

        let g:SuperTabDefaultCompletionType = '<c-x><c-o>'

        if has("gui_running")
          imap <c-space> <c-r>=SuperTabAlternateCompletion("\<lt>c-x>\<lt>c-o>")<cr>
        else " no gui
          if has("unix")
            inoremap <Nul> <c-r>=SuperTabAlternateCompletion("\<lt>c-x>\<lt>c-o>")<cr>
          endif
        endif

        let g:haskellmode_completion_ghc = 0
        autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

        " Tabular bindings
        let g:haskell_tabular = 1
        vmap <leader>a= :Tabularize /=<CR>
        vmap <leader>a; :Tabularize /::<CR>
        vmap <leader>a- :Tabularize /-><CR>

        " fzf bindings
        nnoremap <leader>r :Rg<CR>
        nnoremap <leader>b :Buffers<CR>
        nnoremap <leader>e :Files<CR>
        nnoremap <leader>l :Lines<CR>
        nnoremap <leader>L :BLines<CR>
        nnoremap <leader>c :Commits<CR>
        nnoremap <leader>C :BCommits<CR>
      '';
    };
  };

  xdg.enable = true;

  xsession = {
    enable = true;
    windowManager.i3 = rec {
      enable = true;
      config = {
        modifier = "Mod4";
        bars = [
          { statusCommand = "${pkgs.i3status}/bin/i3status"; }
        ];
        keybindings = let mod = config.modifier; in {
          "${mod}+w" = "exec firefox";
          "${mod}+s" = "exec steam";
          "${mod}+Return" = "exec terminology";
          "${mod}+c" = "kill";
          "${mod}+Shift+h" = "exec dm-tool switch-to-greeter";

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
          "${mod}+2" = "workspace 2";
          "${mod}+3" = "workspace 3";
          "${mod}+4" = "workspace 4";
          "${mod}+5" = "workspace 5";
          "${mod}+6" = "workspace 6";
          "${mod}+7" = "workspace 7";
          "${mod}+8" = "workspace 8";
          "${mod}+9" = "workspace 9";
          "${mod}+0" = "workspace 10";
          "${mod}+Shift+1" = "move container to workspace 1";
          "${mod}+Shift+2" = "move container to workspace 2";
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
        for_window [class="^.*"] border none
      '';
    };
  };
}
