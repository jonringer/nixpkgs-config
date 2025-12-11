pkgs: withGUI: with pkgs; [
  # these files are meant to be installed in all scenarios
  bat
  binutils
  bottom
  cabal-install
  cachix
  cargo
  claude-code
  cmake

  deadnix
  dbus
  direnv
  eza
  fd
  git
  git-absorb
  ghc
  glances
  gnupg                         # gpg command
  gnumake
  hicolor-icon-theme # lutris
  htop

  llvm

  manix
  nix-index
  nix-template
  nix-tree
  nix-update
  nixpkgs-fmt
  nixpkgs-review
  nodejs # needed for coc vim plugins
  openal
  perl # for fzf history
  python3
  ranger
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
  rust-analyzer

  #haskell dependencies
  haskellPackages.hlint

  # so neovim can copy to clipboard
  xclip
  wl-clipboard
] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
  #mono
  #niv
  ntfs3g
  usbutils

] ++ pkgs.lib.optionals withGUI [
  # intended to be installed with an X11 or wayland session
  brightnessctl
  firefox
  discord
  dwarf-fortress-packages.dwarf-fortress-full
  pavucontrol  # pulseaudio configuration
  lutris
  #shutter # screenshots
  vlc

  tmate
]

