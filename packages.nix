pkgs: withGUI: with pkgs; [
  # these files are meant to be installed in all scenarios
  bat
  binutils
  bottom
  cabal-install
  cargo
  cmake

  dbus
  direnv
  eza
  fd
  git
  git-absorb
  gitAndTools.hub
  ghc
  glances
  gnupg                         # gpg command
  gnumake
  hicolor-icon-theme # lutris
  htop

  manix
  nix-index
  nix-template
  nix-update
  nixpkgs-review
  nodejs # needed for coc vim plugins
  openal
  perl # for fzf history
  python3
  ranger
  rnix-lsp
  rustc
  # stack broken

  tig
  tree
  watson
  wget

  # vim plugin dependencies
  fzf
  ripgrep
  elmPackages.elm-format

  #haskell dependencies
  haskellPackages.hlint

  # so neovim can copy to clipboard
  xclip
] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
  mono
  niv
  ntfs3g
  usbutils

  # for work
  vault
  consul

] ++ pkgs.lib.optionals withGUI [
  # intended to be installed with an X11 or wayland session
  brightnessctl
  enlightenment.terminology
  firefox
  discord
  (dwarf-fortress-packages.dwarf-fortress-full.override {
    dfVersion = "0.47.04";
    theme = dwarf-fortress-packages.themes.phoebus;
    enableIntro = false;
    enableFPS = true;
  })
  pavucontrol  # pulseaudio configuration
  lutris
  nerdfonts
  obs-studio
  #shutter # screenshots
  spotify
  teams
  vlc

  tmate
]

