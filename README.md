# nixpkgs-config

My home nixos configuration

```bash
mkdir -p ~/.config/
git clone git@github.com:jonringer/nixpkgs-config.git ~/.config/nixpkgs
```

if running this on a remote machine, change the value of the `withGUI` file
```bash
$ echo "false" > withUI
```

To apply changes:
```bash
$ home-manager switch
```
