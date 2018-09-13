final: previous:

let
  inherit (final) callPackage;
in

{
  buildFlatpak = callPackage (fetchGit {
    url = https://github.com/serokell/nix-flatpak;
    rev = "3ceb79f92e80c84a4360badd721ff87a214a6932";
  }) {};

  buildMacOSApp = callPackage (fetchGit {
    url = https://github.com/serokell/nix-macos-app;
    rev = "192f3c22b4270be84aef9176fdf52a41d0d85b32";
  }) {};

  mixToNix = callPackage (fetchGit {
    url = https://github.com/serokell/nix2mix;
    rev = "2353aac85f7d5923d7da997a353326e18899c595";
  }) {};

  stackToNix = import (fetchGit {
    url = https://github.com/serokell/stack4nix;
    rev = "4229799a07ef7d560ba0fa71cff11c01840f27be";
  }) { pkgs = final; };
}
