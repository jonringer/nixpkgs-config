{
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

    suspend="systemctl suspend";
  };

  initExtra = ''
    set -o vi  # enable vi-like control
    export EDITOR=vim

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
  '';
}

