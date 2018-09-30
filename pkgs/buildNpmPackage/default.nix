{ stdenvNoCC, writeShellScriptBin, writeText, stdenv, fetchurl, makeWrapper, nodejs-10_x }:
with stdenv.lib;
let
  inherit (builtins) fromJSON toJSON split;

  depsToFetches = deps: concatMap depToFetch (attrValues deps);
  depFetchOwn = { resolved, integrity, ... }: let
    ssri = split "-" integrity; # standard subresource integrity
    hashType = head ssri;
    hash = elemAt ssri 2;
  in nameValuePair resolved (fetchurl {
      url = resolved;
      "${hashType}" = hash;
    });

  depToFetch = args @ { resolved ? null, dependencies ? {}, ... }:
    (optional (resolved != null) (depFetchOwn args)) ++ (depsToFetches dependencies);

  npmCacheInput = lock: writeText "npm-cache-input.json" (toJSON (listToAttrs (depToFetch lock)));

  patchShebangs = writeShellScriptBin "patchShebangs.sh" ''
    set -e
    source ${stdenvNoCC}/setup
    patchShebangs "$@"
  '';

  shellWrap = writeShellScriptBin "npm-shell-wrap.sh" ''
    set -e
    if [ ! -e .shebangs_patched ]; then
      ${patchShebangs}/bin/patchShebangs.sh .
      touch .shebangs_patched
    fi
    exec bash "$@"
  '';
in
args @ { lockfile, src, buildInputs ? [], ... }:
let
  lock = fromJSON (readFile lockfile);
in
stdenv.mkDerivation ({
  inherit (lock) version;
  name = "${lock.name}-${lock.version}";

  XDG_CONFIG_DIRS = ".";
  NO_UPDATE_NOTIFIER = true;
  preBuildPhases = [ "npmCachePhase" ];
  preInstallPhases = [ "npmPackPhase" ];
  npm_config_offline = true;
  npm_config_script_shell = "${shellWrap}/bin/npm-shell-wrap.sh";
  npm_config_cache = "./npm-cache";
  installJavascript = true;
  npmCachePhase = ''
    node ${./mkcache.js} ${npmCacheInput lock}
  '';
  buildPhase = ''
    eval "$preBuild"
    npm ci
    eval "$postBuild"
  '';
  # make a package .tgz (no way around it)
  npmPackPhase = ''
    npm prune --production
    npm pack --ignore-scripts
  '';
  # unpack the .tgz into output directory and add npm wrapper
  installPhase = ''
    mkdir -p $out/bin
    tar xzvf ./${lock.name}-${lock.version}.tgz -C $out --strip-components=1
    if $installJavascript; then
      cp -R node_modules $out/
      makeWrapper ${nodejs-10_x}/bin/npm $out/bin/npm --run "cd $out"
    fi
  '';
} // args // { buildInputs = [ nodejs-10_x makeWrapper ] ++ buildInputs; })
