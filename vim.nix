pkgs:
{
  enable = true;
  defaultEditor = true;
  coc.enable = true;
  coc.settings = import ./coc-settings.nix pkgs;

  viAlias = true;
  vimAlias = true;
  plugins = with pkgs.vimPlugins; [
    coc-clangd
    coc-nvim
    nvim-lspconfig

    editorconfig-vim
    fzf-vim
    fzfWrapper
    #LanguageClient-neovim
    lightline-vim
    nerdtree
    supertab
    tabular
    vim-better-whitespace
    vim-multiple-cursors
    vim-surround
    #vimproc
    #vimproc-vim

    # themes
    wombat256

    # language packages
    # Elixir
    vim-elixir

    # Cue
    vim-cue

    # Elm
    elm-vim

    # HCL
    vim-hcl

    # Haskell
    vim-hoogle
    neco-ghc
    haskell-vim
    hlint-refactor-vim
    ghc-mod-vim

    # Hocon
    vim-hocon

    # Nix
    vim-nix

    # Csharp
    vim-csharp

    # Powershell
    vim-ps1

    # Python
    #semshi

    # rust
    #coc-rust-analyzer
    #YouCompleteMe
    vim-toml

    # sql
    sqlite-lua
  ];

  extraPackages = with pkgs; [
    #rust-analyzer
  ];

  extraConfig = builtins.readFile ./vim-extra-conf.viml;
}

