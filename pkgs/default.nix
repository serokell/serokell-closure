final: previous:

let
  inherit (final) callPackage;

  gitignore = import (fetchGit {
    url = https://github.com/siers/nix-gitignore;
    ref = "v1.0.2";
    rev = "d103d389fd814fa2b854b80d5138c95c7cc51dab";
  }) { inherit (final) lib; };
in

{
  buildFlatpak = callPackage (fetchGit {
    url = https://github.com/serokell/nix-flatpak;
    rev = "76dc0f06d21f6063cb7b7d2291b8623da24affa9";
  }) {};

  buildNpmPackage = callPackage ./buildNpmPackage {};

  buildMacOSApp = callPackage (fetchGit {
    url = https://github.com/serokell/nix-macos-app;
    rev = "192f3c22b4270be84aef9176fdf52a41d0d85b32";
  }) {};

  gitIgnore = root: aux:
    gitignore.gitignoreSourceAux (aux ++ [ ".git" ]) root;

  mixToNix = callPackage (fetchGit {
    url = https://github.com/serokell/mix2nix;
    rev = "2353aac85f7d5923d7da997a353326e18899c595";
  }) {};

  stackToNix = import (fetchGit {
    url = https://github.com/serokell/stack4nix;
    rev = "c0ebe262039846feec9e9c6414bf5f00cdfc3ba9";
  }) { pkgs = final; };
}
