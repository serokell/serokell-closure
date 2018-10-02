final: previous:

let
  inherit (final) callPackage runCommand lib;

  gitignore = import (fetchGit {
    url = https://github.com/siers/nix-gitignore;
    ref = "v1.0.2";
    rev = "7a2a637fa4a753a9ca11f60eab52b35241ee3c2f";
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
    url = https://github.com/serokell/mix2nix;
    rev = "2353aac85f7d5923d7da997a353326e18899c595";
  }) {};

  stackToNix = import (fetchGit {
    url = https://github.com/serokell/stack4nix;
    rev = "e227092e52726cfd41cba9930c02691eb6e61864";
  }) { pkgs = final; };
}
