final: previous:

let
  inherit (final) callPackage;
in

{
  buildFlatpak = callPackage (fetchGit {
    url = https://github.com/serokell/nix-flatpak;
    rev = "76dc0f06d21f6063cb7b7d2291b8623da24affa9";
  }) {};

  buildMacOSApp = callPackage (fetchGit {
    url = https://github.com/serokell/nix-macos-app;
    rev = "192f3c22b4270be84aef9176fdf52a41d0d85b32";
  }) {};

  mixToNix = callPackage (fetchGit {
    url = https://github.com/serokell/mix2nix;
    rev = "2353aac85f7d5923d7da997a353326e18899c595";
  }) {};

  stackToNix = import (fetchGit {
    url = https://github.com/serokell/stack4nix;
    rev = "1950ff0d174ca891e092f53ed39121c812c7e149";
  }) { pkgs = final; };
}
