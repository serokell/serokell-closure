{ stdenvNoCC, writeShellScriptBin, writeText, stdenv, fetchurl, nodejs-10_x }:
let
  inherit (builtins) fromJSON toJSON readFile split head elemAt foldl';

  deps-to-fetches = base: deps: builtins.foldl' (a: b: a // (dep-to-fetch b)) base (builtins.attrValues deps);
  dep-own-fetch = { resolved, integrity, ... }: let
    ssri = split "-" integrity;
    hashtype = head ssri;
    hash = elemAt ssri 2;
  in {
    "${resolved}" = fetchurl {
      url = resolved;
      "${hashtype}" = hash;
    };
  };

  dep-to-fetch = args @ { resolved ? null, dependencies ? {}, ... }:
    deps-to-fetches (if isNull resolved then {} else dep-own-fetch args) dependencies;
  npm-cache-input = lock: writeText "npm-cache-input.json" (toJSON (dep-to-fetch lock));

  patchShebangs = writeShellScriptBin "patchShebangs.sh" ''
    set -e
    source ${stdenvNoCC}/setup
    patchShebangs "$@"
  '';
  shellWrap = writeShellScriptBin "npm-shell-wrap.sh" ''
    set -e
    if [ ! -e node_modules/shebangs_patched ]; then
      ${patchShebangs}/bin/patchShebangs.sh .
      touch node_modules/shebangs_patched
    fi
    exec bash "$@"
  '';
in
args @ { lockfile, src, buildInputs ? [], ... }:
let lock = fromJSON (readFile lockfile); in
stdenv.mkDerivation (args // {
  inherit (lock) version;
  name = "${lock.name}-${lock.version}";
  inherit src;

  buildInputs = [
    nodejs-10_x
  ] ++ buildInputs;

  XDG_CONFIG_DIRS = ".";
  NO_UPDATE_NOTIFIER = true;
  buildPhase = ''
    echo making cache
    node ${./mkcache.js} ${npm-cache-input lock}
    echo installing
    npm ci --cache=./npm-cache --offline --script-shell=${shellWrap}/bin/npm-shell-wrap.sh
    npm prune --production --offline --cache=./npm-cache
    npm pack --ignore-scripts --offline --cache=./npm-cache
  '';

  installPhase = ''
    mkdir -p $out/bin
    tar xzvf ./${lock.name}-${lock.version}.tgz -C $out --strip-components=1
    cp -R node_modules $out/
    makeWrapper ${nodejs-10_x}/bin/npm $out/bin/npm --run "cd $out"
  '';
})
