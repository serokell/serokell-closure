self: super:

let
  inherit (self) callPackage runCommand lib;

  srk = import ./lib { pkgs = self; };

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

  darwin = super.darwin // {
    security_tool = runCommand "security_tool" {} ''
      mkdir -p $out/bin
      ln -s /usr/bin/security $out/bin/security
    '';
  };

  mixToNix = callPackage (fetchGit {
    url = https://gitlab.com/transumption/mix-to-nix;
    rev = "d66c85b45eb9d0c662fe5b32cbcf3fb6529423ca";
  }) {};

  stackToNix = import (fetchGit {
    url = https://github.com/serokell/stack-to-nix;
    rev = "28e690d3eddd47c59982c7fbf4f950320ff7ff69";
  }) { pkgs = self; };

  haskellPackages = super.haskellPackages.override { overrides = self: super: {
    hackage2nix = name: version: self.haskellSrc2nix {
      name   = "${name}-${version}";
      sha256 = ''$(sed -e 's/.*"SHA256":"//' -e 's/".*$//' "${all-cabal-hashes-component name version "json"}")'';
      src    = all-cabal-hashes-component name version "cabal";
    };
  };};

}
