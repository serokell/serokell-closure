#!/usr/bin/env bash
set -eux
pushd ../nixpkgs
TAG=$(date +%FT%T | tr -cd '[0-9]')
git tag "$TAG"
COMMIT=$(git rev-parse HEAD)
git push git@github.com:serokell/nixpkgs.git "$TAG"
popd
cat <<EOF > ./nixpkgs.nix
fetchGit {
  url = https://github.com/serokell/nixpkgs;
  ref = "$TAG";
  rev = "$COMMIT";
}
EOF
git commit ./nixpkgs.nix -m "Bump nixpkgs"
