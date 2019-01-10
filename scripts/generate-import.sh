#!/usr/bin/env nix-shell
#! nix-shell -i bash -p yq jq curl
set -eou pipefail
[[ ! -z ${DEBUG:-} ]] && set -x
if [[ ! -e ~/.config/hub ]]; then
    echo "Error: This script requires a working 'hub' setup. Please install it and log in with it" > /dev/stderr
    exit 1
fi
TOKEN="Authorization: token $(yq -r '.["github.com"][0].oauth_token' ~/.config/hub)"
REPO=serokell/serokell-closure
REV=$(curl -H "$TOKEN" -s "https://api.github.com/repos/$REPO/branches/master" | jq -r .commit.sha)
REF=$(curl -H "$TOKEN" -s "https://api.github.com/repos/$REPO/tags" | jq -r 'map(select(.commit.sha == "'"$REV"'"))[0].name')

if [[ $REF == null ]]; then
    echo "No tag found for $REV."
    # shellcheck disable=SC2016
    echo 'Create one with: git tag $(date +"%Y%m%d%H%M%S"); git push origin $_'
    read -p "Do it automatically? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        REF=$(date +"%Y%m%d%H%M%S")
        curl -H "$TOKEN" -d '{"ref": "refs/tags/'"$REF"'", "sha": "'"$REV"'"}' -X POST "https://api.github.com/repos/$REPO/git/refs"
    else
        exit 1
    fi
fi

cat <<EOF
import (fetchGit {
  url = https://github.com/$REPO;
  rev = "$REV";
  ref = "$REF";
})
EOF
