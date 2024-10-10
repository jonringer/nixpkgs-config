# nixpkgs-config

Originally, this was for managing my `~/.config/nixpkgs` files, but evolved into
my home-manager configuration.

My home-manager configuration. Meant to work across linux and macOS.

```bash
mkdir -p ~/.config/
git clone git@github.com:jonringer/nixpkgs-config.git ~/.config/nixpkgs
```

if running this on a remote machine, change the value of the `withGUI` specialArg
```bash
...
extraSpecialArgs = {
  withGUI = false;
};
```

To apply changes:
```bash
$ nix run .#home-manager -- switch --flake .#<configuration>
# or
$ nix develop
# home-manager -- switch --flake .#<configuration>
```
