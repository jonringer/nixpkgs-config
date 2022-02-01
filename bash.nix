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
    bro="bitte rebuild --only";
    g="git";
    gco="git checkout";
    gst="git status";
    nfl="nix flake lock";
    nflu="nix flake lock --update-input";
    vimdiff="nvim -d";
    vim="nvim";
    vi="nvim";
    opt=''manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf --ansi --preview="manix '{}' | sed 's/type: /> type: /g' | bat -l Markdown --color=always --plain"'';
    to32="nix-hash --to-base32 --type sha256";

    suspend="systemctl suspend";
  };

  initExtra = ''
    set -o vi  # enable vi-like control
    export EDITOR=nvim

    # not sure why this stopped working, but it's annoying
    git_prompt_path=${pkgs.git}/share/bash-completion/completions/git-prompt.sh
    [ -f "$git_prompt_path" ] && source "$git_prompt_path"
    git_compl_path=${pkgs.git}/share/bash-completion/completions/git
    [ -f "$git_compl_path" ] && source "$git_compl_path"

    RED="\033[0;31m"
    GREEN="\033[0;32m"
    NO_COLOR="\033[m"
    BLUE="\033[0;34m"

    git_prompt_path=${pkgs.git}/share/bash-completion/completions/git-prompt.sh
    if [ -f "$git_prompt_path" ] && ! command -v __git_ps1 > /dev/null; then
      source "$git_prompt_path"
    fi

    prompt_symbol=$(test "$UID" == "0" && echo "$RED#$NO_COLOR" || echo "$")
    export PS1="$RED[\t] $GREEN\u@\h $NO_COLOR\w$BLUE\`__git_ps1\`$NO_COLOR\n$prompt_symbol "

    export PATH=$PATH:~/.cargo/bin:~/.config/nixpkgs/bin

    # bat utilities
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"

    if [[ "$OSTYPE" == "darwin"* ]]; then
      # on mac, give support to wombat256 colors
      export TERM=xterm-256color
    fi

    if [ -e "$HOME"/.config/git_token ]; then
        export GITHUB_API_TOKEN=$(cat "$HOME"/.config/git_token)
        export GITHUB_TOKEN=$(cat "$HOME"/.config/git_token)
    fi

    fetch_hashi_creds() {
      export NOMAD_TOKEN="$(vault read -field secret_id nomad/creds/developer)"
      export CONSUL_HTTP_TOKEN="$(vault read -field token consul/creds/developer)"
    }

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
      rg --files ''${1:-.} | fzf --preview 'bat -f {}' | xargs $EDITOR
    }
    # Search content and Edit
    se() {
      fileline=$(rg -n ''${1:-.} | fzf | awk '{print $1}' | sed 's/.$//')
      $EDITOR ''${fileline%%:*} +''${fileline##*:}
    }

    # Search git log, preview shows subject, body, and diff
    fl() {
      git log --oneline --color=always | fzf --ansi --preview="echo {} | cut -d ' ' -f 1 | xargs -I @ sh -c 'git log --pretty=medium -n 1 @; git diff @^ @' | bat --color=always" | cut -d ' ' -f 1 | xargs git log --pretty=short -n 1
    }

    nbfkg() {
      nix build -f . --keep-going $@
    }

    battail() {
      tail -f $@ | bat --paging=never -l log
    }

    # a doesn't really make sense, just the second letter
    a() {
      cd ~/projects/basinix
    }

    c() {
      cd ~/.config/nixpkgs/
    }

    n() {
      cd ~/projects/nixpkgs
    }

    w() {
      cd ~/work
    }

    m() {
      cd ~/work/mantis-ops/
    }

    b() {
      cd ~/work/bitte/
    }

    h() {
      cd ~
    }

    p() {
      cd ~/projects
    }

    lo() {
      lorri shell
    }

    ns() {
      nix-shell
    }

    nrp() {
      nix-review pr --skip-package home-assistant --disable-aliases $@
    }

    if ! command -v vim > /dev/null; then
      vim() {
        nvim $@
      }
    fi

    if ! command -v vi > /dev/null; then
      vim() {
        nvim $@
      }
    fi

    gd() {
      git diff --name-only --diff-filter=d $@ | xargs bat --diff
    }

    push_bot() {
      local branch=$(git rev-parse --abbrev-ref HEAD)
      git push git@github.com:r-ryantm/nixpkgs.git ''${branch}:''${branch} $@
    }

    update_nixpkgs_homepage() {
      if [ "$#" -lt 3 ]; then
        echo "Please provide: [installable] [old-homepage] [new-homepage]"
        return 1
      fi

      local installable=$1
      local old_homepage=$2
      local new_homepage=$3
      local branch_name="update-''${installable}-homepage"

      pushd "''${NIXPKGS_ROOT:-/home/jon/projects/nixpkgs}"

      rg -l "$old_homepage" | xargs sed -i -e "s|$old_homepage|$new_homepage|g"

      if [[ $(git diff --stat) == "" ]]; then
        echo "No changes were made"
        return 1
      fi

      git checkout master
      git checkout -b ''${branch_name}
      git add pkgs/
      git diff HEAD
      git commit -v -m "''${installable}: update homepage"

      git push jonringer ''${branch_name}

      git checkout master
      popd
    }

    unh() {
      update_nixpkgs_homepage $@
    }
  '';
}

