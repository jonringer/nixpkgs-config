pkgs:
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
  indentLine = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "indentLine";
    version = "2019-02-22";
    src = pkgs.fetchFromGitHub {
      owner = "Yggdroot";
      repo = "indentLine";
      rev = "47648734706fb2cd0e4d4350f12157d1e5f4c465";
      sha256 = "0739hdvdfa1lm209q4sl75jvmf2k03cvlka7wv1gwnfl00krvszs";
    };
  };

in
{
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
        vim-surround
        vimproc
        vimproc-vim

        # themes
        wombat256

        # Visual additions
        indentLine

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

        # Powershell
        vim-ps1

        # Python
        semshi
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
}

