self: super:

let
  inherit (self) callPackage runCommand lib;

  srk = import ./lib { pkgs = self; };

  sources = import ../nix/sources.nix;

  all-cabal-hashes-component = name: version: type:
    builtins.fetchurl
    "https://raw.githubusercontent.com/commercialhaskell/all-cabal-hashes/hackage/${name}/${version}/${name}.${type}";

in rec {
  inherit (srk) checkTrailingWhitespace constGitIgnore gitIgnore runCheck;

  buildFlatpak = callPackage sources.nix-flatpak { };

  inherit (callPackage sources.nix-npm-buildpackage { })
    buildNpmPackage buildYarnPackage;

  buildMacOSApp = callPackage sources.nix-macos-app { };

  darwin = super.darwin // {
    security_tool = runCommand "security_tool" { } ''
      mkdir -p $out/bin
      ln -s /usr/bin/security $out/bin/security
    '';
  };

  mixToNix = callPackage sources.mix-to-nix { };

  stackToNix = import sources.stack-to-nix { pkgs = self; };

  haskellPackages = super.haskellPackages.override {
    overrides = self: super: {
      hackage2nix = name: version:
        self.haskellSrc2nix {
          name = "${name}-${version}";
          sha256 = ''
            $(sed -e 's/.*"SHA256":"//' -e 's/".*$//' "${
              all-cabal-hashes-component name version "json"
            }")'';
          src = all-cabal-hashes-component name version "cabal";
        };
    };
  };

}
