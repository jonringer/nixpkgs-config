{
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
  allowUnfree = true;
  permittedInsecurePackages = [
    "p7zip-16.02"
  ];
}
