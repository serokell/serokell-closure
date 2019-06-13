final: previous:

let
  inherit (final) callPackage runCommand lib;

  gitignore = import (fetchGit {
    url = https://github.com/siers/nix-gitignore;
    ref = "v1.0.2";
    rev = "7a2a637fa4a753a9ca11f60eab52b35241ee3c2f";
  }) { inherit (final) lib; };
  all-cabal-hashes-component = name: version: type:
    builtins.fetchurl "https://raw.githubusercontent.com/commercialhaskell/all-cabal-hashes/hackage/${name}/${version}/${name}.${type}";
in

{
  buildFlatpak = callPackage (fetchGit {
    url = https://github.com/serokell/nix-flatpak;
    rev = "76dc0f06d21f6063cb7b7d2291b8623da24affa9";
  }) {};

  inherit (callPackage (fetchGit {
    url = https://github.com/serokell/nix-npm-buildpackage;
    rev = "918d604bd172760d4b03333b286d284f63671941";
    ref = "20181120151732";
  }) {}) buildNpmPackage buildYarnPackage;

  buildMacOSApp = callPackage (fetchGit {
    url = https://github.com/serokell/nix-macos-app;
    rev = "ecd2e85f30033c845ed13c5de85212b8d4d53361";
  }) {};

  gitIgnore = root: aux:
    gitignore.gitignoreSourceAux (aux ++ [ ".git" ]) root;

  # `constGitIgnore pathname root aux` returns a builtins.path
  # (setting the name to pathname so that the source directory name is
  # constant and does not depend on the current directory name),
  # filtering out not just .git directories (using
  # `lib.cleanSourceFilter`) but also files ignored by git (using
  # siers' nix-gitignore).  For example, to use the name "fooBar" and
  # the current directory and not add any additional gitignores
  # besides those in the .gitignore file, use:
  #
  #   constGitIgnore "fooBar" ./. []
  #
  constGitIgnore = with gitignore; pathname: root: aux:
    builtins.path {
      name    = pathname;
      path    = root;
      filter  = name: type:
        gitignoreFilter (gitignoreCompileIgnore aux root) root name type
        && lib.cleanSourceFilter name type;
        # NB: gitignoreCompileIgnore currently adds .gitignore (as
        # does gitignoreFilterSourceAux), which may be a bug
    };

  darwin = previous.darwin // {
    security_tool = runCommand "security_tool" {} ''
      mkdir -p $out/bin
      ln -s /usr/bin/security $out/bin/security
    '';
  };

  mixToNix = callPackage (fetchGit {
    url = https://github.com/serokell/mix-to-nix;
    rev = "a7e109574a84fc0bcf811a5cac7eefb6317d2efa";
  }) {};

  nginxStable = previous.nginxStable.overrideAttrs (super: {
    patches = (super.patches or []) ++ [./nix-etag-1.15.4.patch];
  });

  stackToNix = import (fetchGit {
    url = https://github.com/serokell/stack-to-nix;
    rev = "28e690d3eddd47c59982c7fbf4f950320ff7ff69";
  }) { pkgs = final; };

  haskellPackages = previous.haskellPackages.override { overrides = final: previous: {
    hackage2nix = name: version: final.haskellSrc2nix {
      name   = "${name}-${version}";
      sha256 = ''$(sed -e 's/.*"SHA256":"//' -e 's/".*$//' "${all-cabal-hashes-component name version "json"}")'';
      src    = all-cabal-hashes-component name version "cabal";
    };
  };};
}
