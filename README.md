# Serokell closure

This is a Nixpkgs pin overlayed with:

- [nix-flatpak](https://github.com/serokell/nix-flatpak) (`buildFlatpak`)
- [nix-macos-app](https://github.com/serokell/nix-macos-app) (`buildMacOSApp`)
- [mix-to-nix](https://github.com/serokell/mix2nix) (`mixToNix`)
- [stack-to-nix](https://github.com/serokell/stack-to-nix) (`stackToNix`)


## Usage
generate the import:
```sh
./scripts/generate-import.sh
```

## About Serokell

`serokell-closure` is maintained and funded with :heart: by
[Serokell](https://serokell.io/). The names and logo for Serokell are trademark
of Serokell OÜ.

We love open source software! See [our other
projects](https://serokell.io/community?utm_source=github) or [hire
us](https://serokell.io/hire-us?utm_source=github) to design, develop and grow
your idea!
