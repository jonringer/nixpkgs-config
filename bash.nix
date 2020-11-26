pkgs: {
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
    ".6"="cd ../../../../../..";
    g="git";
    gco="git checkout";
    gst="git status";
    vimdiff="nvim -d";
    vim="nvim";
    vi="nvim";

    suspend="systemctl suspend";
  };

  initExtra = ''
    set -o vi  # enable vi-like control
    export EDITOR=nvim

    # not sure why this stopped working, but it's annoying
    git_prompt_path=${pkgs.git}/share/bash-completion/completions/git-prompt.sh
    [ -f "$git_prompt_path" ] && source "$git_prompt_path"

    RED="\033[0;31m"
    GREEN="\033[0;32m"
    NO_COLOR="\033[m"
    BLUE="\033[0;34m"

    export PS1="$RED[\t] $GREEN\u@\h $NO_COLOR\w$BLUE\`__git_ps1\`$NO_COLOR\n$ "

    export PATH=$PATH:~/.cargo/bin:~/.config/nixpkgs/bin

    # for coc-rust-analyzer
    export RUST_SRC_PATH=${pkgs.rustPlatform.rustcSrc}

    if [ -e "$HOME"/.config/git_token ]; then
        GITHUB_API_TOKEN=$(cat "$HOME"/.config/git_token)
        GITHUB_TOKEN=$(cat "$HOME"/.config/git_token)
    fi

    if [ -n "$VIRTUAL_ENV" ]; then
      env=$(basename "$VIRTUAL_ENV")
      export PS1="($env) $PS1"
    fi

    if [ -n "$IN_NIX_SHELL" ]; then
      export PS1="(nix-shell) $PS1"
    fi

    if [ ! -z "$WSL_DISTRO_NAME" -a -d ~/.nix-profile/etc/profile.d ]; then
      for f in ~/.nix-profile/etc/profile.d/* ; do
        source $f
      done
    fi

    editline() { nvim ''${1%%:*} +''${1##*:}; }
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
      rg --files ''${1:-.} | fzf --preview 'cat {}' | xargs $EDITOR
    }
    # Search content and Edit
    se() {
      fileline=$(rg -n ''${1:-.} | fzf | awk '{print $1}' | sed 's/.$//')
      $EDITOR ''${fileline%%:*} +''${fileline##*:}
    }

    nbfkg() {
      nix build -f . --keep-going $@
    }

    n() {
      cd ~/projects/nixpkgs
    }

    h() {
      cd ~
    }

    a() {
      cd ~/projects/AzureMlCli
    }

    lo() {
      lorri shell
    }

    ns() {
      nix-shell
    }

    nrp() {
      nix-review pr $@
    }

    push_bot() {
      local branch=$(git rev-parse --abbrev-ref HEAD)
      git push git@github.com:r-ryantm/nixpkgs.git ''${branch}:''${branch} $@
    }
  '';
}

