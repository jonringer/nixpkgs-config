pkgs:
{
  enable = true;
  viAlias = true;
  vimAlias = true;
  plugins = with pkgs.vimPlugins; [
    #coc-nvim
    fzf-vim
    fzfWrapper
    LanguageClient-neovim
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

    # Elm
    elm-vim

    # Haskell
    vim-hoogle
    neco-ghc
    haskell-vim
    hlint-refactor-vim
    ghc-mod-vim

    # Nix
    vim-nix

    # Csharp
    vim-csharp

    # Powershell
    vim-ps1

    # Python
    semshi

    # rust
    coc-rust-analyzer
    YouCompleteMe
    vim-toml
  ];

  extraPackages = with pkgs; [
    rust-analyzer
  ];

  extraConfig = ''
    colorscheme wombat256mod
    syntax on
    filetype plugin indent on

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
    autocmd FileType markdown setlocal conceallevel=0

    " Tabular bindings
    let g:haskell_tabular = 1
    vmap <leader>a= :Tabularize /=<CR>
    vmap <leader>a; :Tabularize /::<CR>
    vmap <leader>a- :Tabularize /-><CR>
    vmap <leader>a# :Tabularize /#<CR>

    " fzf bindings
    nnoremap <leader>r :Rg<CR>
    nnoremap <leader>b :Buffers<CR>
    nnoremap <leader>e :Files<CR>
    nnoremap <leader>l :Lines<CR>
    nnoremap <leader>L :BLines<CR>
    nnoremap <leader>c :Commits<CR>
    nnoremap <leader>C :BCommits<CR>

    let g:ycm_language_server =
    \ [
    \   {
    \     'name': 'rust',
    \     'cmdline': ['rust-analyzer'],
    \     'filetypes': ['rust'],
    \     'project_root_files': ['Cargo.toml']
    \   }
    \ ]

    let g:LanguageClient_serverCommands = {
    \ 'rust': ['rust-analyzer'],
    \ }

    "CTRL-t to toggle tree view with CTRL-t
    nmap <silent> <C-t> :NERDTreeToggle<CR>
    "Set F2 to put the cursor to the nerdtree
    nmap <silent> <F2> :NERDTreeFind<CR>
  '';
}

