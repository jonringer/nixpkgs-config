pkgs: with pkgs; [
  binutils
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
  ntfs3g
  openal
  pavucontrol  # pulseaudio configuration
  python36
  ranger
  rustc
  shutter # screenshots
  spotify
  # stack broken
  steam

  tree
  usbutils
  vlc
  wget
  ytop

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

