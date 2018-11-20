# Serokell closure

This is a Nixpkgs pin overlayed with:

- [nix-flatpak](https://github.com/serokell/nix-flatpak) (`buildFlatpak`)
- [nix-macos-app](https://github.com/serokell/nix-macos-app) (`buildMacOSApp`)
- [mix-to-nix](https://github.com/serokell/mix2nix) (`mixToNix`)
- [stack-to-nix](https://github.com/serokell/stack-to-nix) (`stackToNix`)


## Usage
generate the import:
```sh
#!/usr/bin/env bash
REPO=serokell/serokell-closure
REV=$(curl -s https://api.github.com/repos/$REPO/branches/master | jq -r .commit.sha)
cat <<EOF
let
  pkgs = import (fetchGit {
    url = https://github.com/$REPO;
    rev = "$REV";
    ref = "$(curl -s https://api.github.com/repos/$REPO/tags | jq -r 'map(select(.commit.sha == "'$REV'"))[0].name')"
  });
in
EOF
```

