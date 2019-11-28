{ pkgs }: with pkgs;
let
  gitignore = import (import ../../nix/sources.nix).nix-gitignore { inherit lib; };
in
{
  /*
  * Run a series of commands only for their exit status, producing an empty
  * closure.
  */
  runCheck = script: src:  runCommand "check" {} ''
    src="${src}"
    ${script}
    touch $out
  '';

  /*
  * Check the given target path for files with trailing whitespace, fail if any
  * are found
  */
  checkTrailingWhitespace = runCheck ''
    files=$(grep --recursive --files-with-matches --binary-files=without-match '[[:blank:]]$' "$src" || true)
    if [[ ! -z $files ]];then
      echo '  Files with trailing whitespace found:'
      for f in "''${files[@]}"; do
        echo "  * $f" | sed -re "s|$src/||"
      done
      exit 1
    fi
  '';

  gitIgnore = root: aux:
    gitignore.gitignoreSourceAux (aux ++ [ ".git" ]) root;

  /*
  * `constGitIgnore pathname root aux` returns a builtins.path
  * (setting the name to pathname so that the source directory name is
  * constant and does not depend on the current directory name),
  * filtering out not just .git directories (using
  * `lib.cleanSourceFilter`) but also files ignored by git (using
  * siers' nix-gitignore).  For example, to use the name "fooBar" and
  * the current directory and not add any additional gitignores
  * besides those in the .gitignore file, use:
  *
  *   constGitIgnore "fooBar" ./. []
  */
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

}
