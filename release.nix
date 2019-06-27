let
  overlay = import ./pkgs;
  nixpkgs = import (import ./nixpkgs.nix) {
    overlays = [ overlay ];
  };

  source = nixpkgs.constGitIgnore "serokell-closure-src" ./. [];
in
with nixpkgs;

# Attempt to build all derivations in our overlay
(lib.filterAttrs (n: _: lib.hasAttr n (overlay {} {})) nixpkgs) // {
  # Check all files in the repo for trailing whitespace
  check-whitespace = checkTrailingWhitespace source;
}
