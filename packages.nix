pkgs: with pkgs; [
  binutils
  bottom
  cabal-install
  cargo
  chromium
  cmake

  dbus
  direnv
  discord
  dwarf-fortress-packages.dwarf-fortress-full
  enlightenment.terminology
  exa
  fd
  firefox
  git
  gitAndTools.hub
  ghc
  glances
  gnupg                         # gpg command
  gnumake
  hicolor-icon-theme # lutris
  htop
  jetbrains.pycharm-community
  jetbrains.rider
  lutris

  mono
  nerdfonts
  nix-update
  nixpkgs-review
  nodejs # needed for coc vim plugins
  ntfs3g
  openal
  pavucontrol  # pulseaudio configuration
  perl # for fzf history
  python36
  ranger
  rnix-lsp
  rustc
  shutter # screenshots
  spotify
  # stack broken
  steam

  teams
  tree
  usbutils
  vlc
  wget

  # vim plugin dependencies
  fzf
  ripgrep

  #haskell dependencies
  haskellPackages.hlint

  # dotnet
  (with dotnetCorePackages; combinePackages [
    sdk_2_1
    sdk_3_0
    sdk_3_1
  ])
]

