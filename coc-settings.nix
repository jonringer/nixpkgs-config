pkgs: with pkgs; {
  "rust-analyzer.serverPath" = "${lib.getBin rust-analyzer}/bin/rust-analyzer";
  languageserver = {
    nix = {
      command = "rnix-lsp";
      rootPatterns = [
        "flake.nix"
        "shell.nix"
      ];
      filetypes = [ "nix" ];
    };
    rust = {
      command = "rust-analyzer";
      rootPatterns = [
        "Cargo.toml"
        "Cargo.lock"
      ];
      filetypes = [ "rust" "rus" ];
    };
  };
}
