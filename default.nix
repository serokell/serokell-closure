import (import ./nixpkgs.nix) {
  overlays = [ (import ./pkgs) ];
}
