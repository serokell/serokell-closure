#!/usr/bin/env bash
set -eou pipefail
[[ ! -z ${DEBUG:-} ]] && set -x

REPO=serokell/serokell-closure
REV=$(curl -s "https://api.github.com/repos/$REPO/branches/master" | jq -r .commit.sha)
REF=$(curl -s "https://api.github.com/repos/$REPO/tags" | jq -r 'map(select(.commit.sha == "'"$REV"'"))[0].name')

if [[ $REF == null ]]; then
    echo "No tag found for $REV."
    # shellcheck disable=SC2016
    echo 'Create one with: git tag $(date +"%Y%m%d%H%M%S"); git push origin $_'
    exit 1
fi

cat <<EOF
let
  pkgs = import (fetchGit {
    url = https://github.com/$REPO;
    rev = "$REV";
    ref = "$REF";
  });
in
EOF
