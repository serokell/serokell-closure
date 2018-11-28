#!/usr/bin/env bash
REPO=serokell/serokell-closure
REV=$(curl -s https://api.github.com/repos/$REPO/branches/master | jq -r .commit.sha)
cat <<EOF
let
  pkgs = import (fetchGit {
    url = https://github.com/$REPO;
    rev = "$REV";
    ref = "$(curl -s https://api.github.com/repos/$REPO/tags | jq -r 'map(select(.commit.sha == "'$REV'"))[0].name')";
  });
in
EOF
