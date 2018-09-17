# Serokell closure

This is a Nixpkgs pin overlayed with:

- [nix-flatpak](https://github.com/serokell/nix-flatpak) (`buildFlatpak`)
- [nix-macos-app](https://github.com/serokell/nix-macos-app) (`buildMacOSApp`)
- [mix-to-nix](https://github.com/serokell/mix2nix) (`mixToNix`)
- [stack-to-nix](https://github.com/serokell/stack-to-nix) (`stackToNix`)


## Usage

```nix
let
  pkgs = import (fetchGit {
    url = https://github.com/serokell/serokell-closure;
    rev = "fa58e033c01d9d416b186ccd514bf628744b1183";
  });
in
```
