Serokell-Closure
===============

This is a re-export for 
- [nix-flatpak](https://github.com/serokell/nix-flatpak) (`buildFlatpak`)
- [nix-macos-app](https://github.com/serokell/nix-macos-app) (`buildMacOSApp`)
- [mix2nix](https://github.com/serokell/mix2nix) (`mixToNix`)
- [stack-to-nix](https://github.com/serokell/stack-to-nix) (`stackToNix`)



usage
-----
```nix
let pkgs = import (fetchGit {
  url = https://github.com/serokell/serokell-closure;
  rev = "fa58e033c01d9d416b186ccd514bf628744b1183";
}); in
```
