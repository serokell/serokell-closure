final: previous:

let
  inherit (final) callPackage runCommand lib;

  srk = import ./lib { pkgs = final; };

  all-cabal-hashes-component = name: version: type:
    builtins.fetchurl "https://raw.githubusercontent.com/commercialhaskell/all-cabal-hashes/hackage/${name}/${version}/${name}.${type}";
in

rec {
  inherit (srk)
    checkTrailingWhitespace
    constGitIgnore
    gitIgnore
    runCheck;

  buildFlatpak = callPackage (fetchGit {
    url = https://github.com/serokell/nix-flatpak;
    rev = "76dc0f06d21f6063cb7b7d2291b8623da24affa9";
  }) {};

  inherit (callPackage (fetchGit {
    url = https://github.com/serokell/nix-npm-buildpackage;
    rev = "fc42625d30aadb3cefef19184baeba6524631b70";
    ref = "20190625164951";
  }) {}) buildNpmPackage buildYarnPackage;

  buildMacOSApp = callPackage (fetchGit {
    url = https://github.com/serokell/nix-macos-app;
    rev = "ecd2e85f30033c845ed13c5de85212b8d4d53361";
  }) {};

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
