#!/usr/bin/env bash
set -euo pipefail
[[ ! -z ${DEBUG:-} ]] && set -x

# Override with `NIXPKGS=/path/to/nixpkgs bump-nixpkgs.sh`
[[ -z ${NIXPKGS:-} ]] && NIXPKGS=$(readlink -f ../nixpkgs)
TAG=$(date +"%Y%m%d%H%M%S")

pushd "$NIXPKGS"
COMMIT=$(git rev-parse HEAD)
git tag "$TAG"
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
fi
