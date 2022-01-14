pkgs: withGUI: with pkgs; [
  # these files are meant to be installed in all scenarios
  bat
  binutils
  bottom
  brightnessctl
  cabal-install
  cargo
  cmake

  dbus
  direnv
  enlightenment.terminology
  exa
  fd
  git
  gitAndTools.hub
  ghc
  glances
  gnupg                         # gpg command
  gnumake
  hicolor-icon-theme # lutris
  htop

  manix
  mono
  niv
  nix-index
  nix-template
  nix-update
  nixpkgs-review
  nodejs # needed for coc vim plugins
  ntfs3g
  openal
  perl # for fzf history
  python3
  ranger
  rnix-lsp
  rustc
  # stack broken

  tig
  tree
  usbutils
  watson
  wget

  # for work
  vault
  consul

  # vim plugin dependencies
  fzf
  ripgrep

  #haskell dependencies
  haskellPackages.hlint

  # dotnet
  (with dotnetCorePackages; combinePackages [
    sdk_3_1
    sdk_5_0
  ])

  # so neovim can copy to clipboard
  xclip
] ++ pkgs.lib.optionals withGUI [
  # intended to be installed with an X11 or wayland session
  firefox
  discord
  (dwarf-fortress-packages.dwarf-fortress-full.override {
    dfVersion = "0.47.04";
    theme = dwarf-fortress-packages.themes.phoebus;
    enableIntro = false;
    enableFPS = true;
  })
  jetbrains.pycharm-community
  nerdfonts
  jetbrains.rider
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

