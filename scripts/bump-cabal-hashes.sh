#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail
[[ ! -z ${DEBUG:-} ]] && set -x

# Override with `NIXPKGS=/path/to/nixpkgs bump-cabal-hashes.sh`
[[ -z ${NIXPKGS:-} ]] && NIXPKGS=$(readlink -f ../nixpkgs)
TAG=$(date +"%Y%m%d%H%M%S")

pushd "$NIXPKGS"

REPO=commercialhaskell/all-cabal-hashes
REV=$(curl -s "https://api.github.com/repos/$REPO/branches/hackage" | jq -r .commit.sha)
URL="https://github.com/$REPO/archive/$REV.tar.gz"
SHA256=$(nix-prefetch-url --unpack "$URL")

cat <<EOF >| ./pkgs/data/misc/hackage/default.nix
{ fetchurl }:

fetchurl {
  url = "$URL";
  sha256 = "$SHA256";
}
EOF

git --no-pager diff ./pkgs/data/misc/hackage/default.nix
echo
read -p "Are you sure you want to commit this? [y/N]" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git commit ./pkgs/data/misc/hackage/default.nix -m 'Bump all-cabal-hashes'
else
    echo 'Aborting'
    exit 1
fi

COMMIT=$(git rev-parse HEAD)
git tag "$TAG"
branch_name="$(git symbolic-ref HEAD 2>/dev/null)"
git push git@github.com:serokell/nixpkgs.git "$branch_name"
git push git@github.com:serokell/nixpkgs.git "$TAG"
popd

cat <<EOF >| ./nixpkgs.nix
fetchGit {
  url = https://github.com/serokell/nixpkgs;
  ref = "$TAG";
  rev = "$COMMIT";
}
EOF

git --no-pager diff ./nixpkgs.nix

echo
read -p "Are you sure you want to commit this? [y/N]" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    branch_name="$(git symbolic-ref HEAD 2>/dev/null)"
    git commit ./nixpkgs.nix -m 'Bump nixpkgs'
    git push git@github.com:serokell/serokell-closure.git "$branch_name"

    git tag "$TAG"
    git push git@github.com:serokell/serokell-closure.git "$TAG"
fi
